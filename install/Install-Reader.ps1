# SPDX-License-Identifier: AGPL-3.0-or-later
# Copyright (c) 2026 Hyeon-Ho Yang
# Independent Windows installer. The Reader application has separate terms.
[CmdletBinding()]
param([string]$InstallPath, [string]$RuntimePath, [switch]$DownloadOnly)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

function Assert-ReaderAncestors([string]$Path) {
    $current = $Path
    while ($current) {
        if (Test-Path -LiteralPath $current) {
            $item = Get-Item -LiteralPath $current -Force
            if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
                throw "Linked/reparse path is not allowed: $current"
            }
            if ($current -ne $Path -and -not $item.PSIsContainer) {
                throw "A parent is not a directory: $current"
            }
        }
        $parent = [IO.Path]::GetDirectoryName($current.TrimEnd('\'))
        if (-not $parent -or $parent -eq $current) { break }
        $current = $parent
    }
}

function Resolve-ReaderPath([string]$Path, [string]$Label, [int]$MaxLength) {
    if (-not $Path -or $Path -notmatch '^[A-Za-z]:[\\/]' -or $Path -match '[<>"|?*%&!^;`()\x00-\x1f]') {
        throw "$Label must be an absolute local drive path without shell metacharacters."
    }
    $parts = $Path.Substring(3).Replace('/', '\').Split('\')
    foreach ($part in $parts) {
        if (-not $part -or $part -eq '.' -or $part -eq '..' -or $part -match '[: .]$|:' -or
            $part -match '^(?i:CON|PRN|AUX|NUL|CLOCK\$|COM[1-9\u00b9\u00b2\u00b3]|LPT[1-9\u00b9\u00b2\u00b3])(?:\.|$)') {
            throw "$Label contains an unsafe path component."
        }
    }
    $full = [IO.Path]::GetFullPath($Path)
    if ($full.Length -gt $MaxLength -or $full -eq [IO.Path]::GetPathRoot($full)) {
        throw "$Label must be a folder path of at most $MaxLength characters."
    }
    $drive = New-Object IO.DriveInfo ([IO.Path]::GetPathRoot($full))
    if ($drive.DriveType -ne [IO.DriveType]::Fixed) { throw "$Label must be on a local fixed drive." }
    Assert-ReaderAncestors $full
    return $full
}

function Read-ReaderMetadata([string]$Path) {
    Assert-ReaderAncestors $Path
    $m = Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($m.schema -ne 'reader-public-install-v1' -or $m.repository -cne 'HHYang95/YANG_Paper_Reader_Public') {
        throw 'Unsupported release metadata schema or repository.'
    }
    if ($m.version -notmatch '^\d+\.\d+\.\d+(?:-[A-Za-z0-9.-]+)?$' -or
        $m.asset.sha256 -notmatch '^[a-fA-F0-9]{64}$' -or
        $m.asset.bytes -isnot [ValueType] -or [decimal]$m.asset.bytes -ne [long]$m.asset.bytes -or
        [long]$m.asset.bytes -le 0 -or [long]$m.asset.bytes -gt 2GB) {
        throw 'Release version, SHA-256 or archive size is invalid (maximum 2 GiB).'
    }
    $url = '^https://github\.com/HHYang95/YANG_Paper_Reader_Public/releases/download/' +
           [regex]::Escape($m.version) + '/[A-Za-z0-9][A-Za-z0-9_.-]*\.zip$'
    if ($m.asset.url -cnotmatch $url -or $m.asset.rootDirectory -cnotmatch '^YANG_Paper_Reader_[A-Za-z0-9][A-Za-z0-9_.-]*$') {
        throw 'The asset must use the exact repository, pinned version URL and expected Reader root directory.'
    }
    return $m
}

function Assert-ReaderOwnedFile([IO.FileStream]$Stream, [string]$Path) {
    Assert-ReaderAncestors $Path
    if (-not ('ReaderArchiveNative' -as [type])) {
        Add-Type -TypeDefinition @'
using System;
using System.IO;
using System.Runtime.InteropServices;
using Microsoft.Win32.SafeHandles;
public static class ReaderArchiveNative {
    [StructLayout(LayoutKind.Sequential)] struct Info {
        public uint Attributes;
        public System.Runtime.InteropServices.ComTypes.FILETIME Creation, Access, Write;
        public uint Volume, SizeHigh, SizeLow, Links, IndexHigh, IndexLow;
    }
    [DllImport("kernel32.dll", SetLastError=true)]
    static extern bool GetFileInformationByHandle(SafeFileHandle handle, out Info info);
    public static void AssertSingleLink(FileStream stream) {
        Info info;
        if (!GetFileInformationByHandle(stream.SafeFileHandle, out info))
            throw new IOException("Cannot inspect the archive cache file.");
        if (info.Links != 1 || (info.Attributes & 0x410) != 0)
            throw new IOException("Archive cache files must be regular, unlinked files.");
    }
}
'@
    }
    [ReaderArchiveNative]::AssertSingleLink($Stream)
}

function Get-ReaderStreamDigest([IO.Stream]$Stream) {
    $position = $Stream.Position
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        $Stream.Position = 0
        return [BitConverter]::ToString($sha.ComputeHash($Stream)).Replace('-', '').ToLowerInvariant()
    } finally { $Stream.Position = $position; $sha.Dispose() }
}

function Open-ReaderArchiveCache([string]$Parent, [string]$Stage, [string]$Destination, $Metadata) {
    $owner = [ordered]@{schema='reader-program-download-v1'; installPath=$Destination.ToLowerInvariant();
        url=[string]$Metadata.asset.url; sha256=([string]$Metadata.asset.sha256).ToLowerInvariant();
        bytes=[long]$Metadata.asset.bytes; rootDirectory=[string]$Metadata.asset.rootDirectory} | ConvertTo-Json -Compress
    $encoding = New-Object Text.UTF8Encoding $false
    $identity = New-Object IO.MemoryStream (,$encoding.GetBytes($owner))
    try { $key = Get-ReaderStreamDigest $identity } finally { $identity.Dispose() }
    $root = Join-Path $Parent ('.reader-download-' + $key)
    Assert-ReaderAncestors $root
    if (-not (Test-Path -LiteralPath $root)) {
        # Publish a complete ownership marker atomically, before any network activity.
        $prepared = Join-Path $Stage 'archive-cache'
        [void][IO.Directory]::CreateDirectory($prepared)
        $marker = [IO.File]::Open((Join-Path $prepared 'owner.json'), 'CreateNew', 'Write', 'None')
        try { $bytes = $encoding.GetBytes($owner); $marker.Write($bytes, 0, $bytes.Length); $marker.Flush($true) }
        finally { $marker.Dispose() }
        try { [IO.Directory]::Move($prepared, $root) }
        catch { if (-not (Test-Path -LiteralPath $root -PathType Container)) { throw } }
    }
    Assert-ReaderAncestors $root
    if (-not (Test-Path -LiteralPath $root -PathType Container)) { throw 'The archive cache is not a directory.' }
    foreach ($item in Get-ChildItem -LiteralPath $root -Force) {
        if ($item.Name -cnotin @('owner.json','archive.part','activity.lock') -or $item.PSIsContainer -or
            ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { throw 'Unrelated or redirected data occupies the archive cache; nothing was overwritten.' }
    }
    $markerPath = Join-Path $root 'owner.json'
    $marker = [IO.File]::Open($markerPath, 'Open', 'Read', 'Read')
    try {
        Assert-ReaderOwnedFile $marker $markerPath
        if ($marker.Length -ne $encoding.GetByteCount($owner)) { throw 'The archive cache ownership marker does not match this installation.' }
        $reader = New-Object IO.StreamReader ($marker, $encoding)
        try { if ($reader.ReadToEnd() -cne $owner) { throw 'The archive cache belongs to a different installation.' } }
        finally { $reader.Dispose() }
    } finally { $marker.Dispose() }
    # CreateNew never opens an unrelated lock file. Windows removes this owned lock
    # when its exclusive handle closes, including after hard process termination.
    $lockPath = Join-Path $root 'activity.lock'
    Assert-ReaderAncestors $lockPath
    try { $lock = [IO.FileStream]::new($lockPath, [IO.FileMode]::CreateNew, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None, 4096, [IO.FileOptions]::DeleteOnClose) }
    catch { throw 'Another installer is using this archive cache, or an unrelated lock occupies it. Retry after the active installer stops.' }
    return [pscustomobject]@{Root=$root; Archive=(Join-Path $root 'archive.part'); Marker=$markerPath; Lock=$lock}
}

function Remove-ReaderArchiveCache($Cache) {
    # Delete only the known owned files; never recursively remove a cache directory.
    foreach ($file in @($Cache.Archive, $Cache.Marker)) {
        Assert-ReaderAncestors $file
        if (Test-Path -LiteralPath $file) {
            $handle = [IO.File]::Open($file, 'Open', 'Read', 'None')
            try { Assert-ReaderOwnedFile $handle $file } finally { $handle.Dispose() }
            [IO.File]::Delete($file)
        }
    }
    $Cache.Lock.Dispose()
    Assert-ReaderAncestors $Cache.Root
    [IO.Directory]::Delete($Cache.Root, $false)
}

function Open-ReaderDownload([uri]$Url, [long]$Start = 0) {
    for ($redirect = 0; $redirect -le 10; $redirect++) {
        if ($Url.Scheme -ne 'https') { throw 'The program download requires HTTPS.' }
        $request = [Net.WebRequest]::Create($Url)
        $request.UserAgent = 'YANG-Paper-Reader-Installer'
        $request.AllowAutoRedirect = $false
        if ($Start -gt 0) { $request.AddRange($Start) }
        try { $response = $request.GetResponse() }
        catch [Net.WebException] { if (-not $_.Exception.Response) { throw }; $response = $_.Exception.Response }
        if ([int]$response.StatusCode -notin @(301, 302, 303, 307, 308)) { return $response }
        try {
            $location = $response.Headers['Location']
            if ([int]$response.StatusCode -notin @(301, 302, 303, 307, 308) -or -not $location) {
                throw "Unexpected program download response: HTTP $([int]$response.StatusCode)."
            }
            $Url = [uri]::new($Url, $location)
        } finally { $response.Dispose() }
    }
    throw 'Too many redirects while downloading the program.'
}

function Invoke-ReaderDownload([string]$Url, [string]$Destination, [long]$ExpectedBytes, [string]$ExpectedSha256) {
    if ($ExpectedBytes -le 0 -or $ExpectedBytes -gt 2GB -or $ExpectedSha256 -notmatch '^[a-fA-F0-9]{64}$') { throw 'Invalid published archive identity.' }
    Assert-ReaderAncestors $Destination
    $output = $null
    try {
        $mode = if (Test-Path -LiteralPath $Destination) { [IO.FileMode]::Open } else { [IO.FileMode]::CreateNew }
        $output = [IO.File]::Open($Destination, $mode, 'ReadWrite', 'None')
        Assert-ReaderOwnedFile $output $Destination
        $freshRetryUsed = $false
        $freshRequested = $false
        if ($output.Length -ge $ExpectedBytes) {
            if ($output.Length -eq $ExpectedBytes -and (Get-ReaderStreamDigest $output) -ieq $ExpectedSha256) {
                Write-Host 'Reusing the complete program archive after size and SHA-256 verification.'
                return
            }
            Write-Host 'The retained complete archive is invalid. Starting one fresh transfer.'
            $freshRetryUsed = $true; $freshRequested = $true
        }
        $buffer = New-Object byte[] 65536
        while ($true) {
            [long]$start = if ($freshRequested) { 0 } else { $output.Length }
            if ($start -gt 0) { Write-Host "Resuming program download at $start of $ExpectedBytes bytes." }
            $response = Open-ReaderDownload $Url $start
            $rangeFailure = $null
            try {
                $status = [int]$response.StatusCode
                if ($status -eq 206) {
                    $match = [regex]::Match([string]$response.Headers['Content-Range'], '^(?i:bytes) ([0-9]+)-([0-9]+)/([0-9]+)$')
                    [long]$first = 0; [long]$last = 0; [long]$total = 0
                    if ($freshRequested -or -not $match.Success -or -not [long]::TryParse($match.Groups[1].Value, [ref]$first) -or
                        -not [long]::TryParse($match.Groups[2].Value, [ref]$last) -or -not [long]::TryParse($match.Groups[3].Value, [ref]$total) -or
                        $first -ne $start -or $last -ne $ExpectedBytes - 1 -or $total -ne $ExpectedBytes -or
                        ($response.ContentLength -ge 0 -and $response.ContentLength -ne $ExpectedBytes - $start)) {
                        $rangeFailure = 'The server returned an invalid program Content-Range or payload length.'
                    }
                } elseif ($status -eq 200) {
                    # A server ignoring Range already supplied the fresh response: do not GET twice.
                    if ($response.ContentLength -ge 0 -and $response.ContentLength -ne $ExpectedBytes) {
                        $rangeFailure = 'The full response length does not match the published archive size.'
                    } else {
                        if ($start -gt 0) { Write-Host 'The server ignored the resume request. Restarting the program download from byte zero using this response.' }
                        $output.SetLength(0); $start = 0
                    }
                } elseif ($status -eq 416) { $rangeFailure = 'The server rejected the requested archive range (HTTP 416).' }
                else { throw "The program download returned HTTP $status. The retained archive prefix was not changed." }
                if (-not $rangeFailure) {
                    $inputStream = $response.GetResponseStream()
                    $output.Position = $start
                    [long]$received = $start
                    $reportedPercent = -5
                    $timer = [Diagnostics.Stopwatch]::StartNew()
                    while (($count = $inputStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                        if ($count -gt $ExpectedBytes - $received) { throw 'The download exceeds the published archive size.' }
                        $output.Write($buffer, 0, $count)
                        $received += $count
                        $percent = [int][Math]::Floor(100.0 * $received / $ExpectedBytes)
                        if ($percent -ge $reportedPercent + 5 -or $timer.Elapsed.TotalSeconds -ge 1 -or $received -eq $ExpectedBytes) {
                            $output.Flush($true)
                            Write-Host "Downloading: $received of $ExpectedBytes bytes ($percent%)."
                            $reportedPercent = $percent; $timer.Restart()
                        }
                    }
                    if ($received -ne $ExpectedBytes) { throw "Program download was interrupted at $received of $ExpectedBytes bytes. The available prefix is retained." }
                }
            } finally { $response.Dispose() }
            if (-not $rangeFailure -and (Get-ReaderStreamDigest $output) -ieq $ExpectedSha256) { return }
            $failure = if ($rangeFailure) { $rangeFailure } else { 'Downloaded archive SHA-256 does not match release metadata.' }
            if ($freshRetryUsed) { throw "$failure The one fresh transfer also failed; the program was not installed." }
            Write-Host "$failure Starting one fresh transfer."
            # Keep the previous prefix until the clean request has a usable full response.
            $freshRetryUsed = $true; $freshRequested = $true
        }
    } finally {
        if ($output) { try { $output.Flush($true) } finally { $output.Dispose() } }
    }
}

function Invoke-ReaderRuntime([string]$SetupPath, [string]$SelectedRuntimePath) {
    & $SetupPath $SelectedRuntimePath | Out-Host
    return [int]$LASTEXITCODE
}

function Expand-ReaderArchive([string]$Archive, [string]$Stage, [string]$Destination, [string]$Root) {
    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [IO.Compression.ZipFile]::OpenRead($Archive)
    try {
        if ($zip.Entries.Count -eq 0 -or $zip.Entries.Count -gt 10000) { throw 'Archive entry count is outside 1..10000.' }
        $nodes = New-Object 'Collections.Generic.Dictionary[string,object]' ([StringComparer]::OrdinalIgnoreCase)
        [long]$total = 0
        foreach ($entry in $zip.Entries) {
            $name = $entry.FullName
            $directory = $name.EndsWith('/')
            if ($name -match '\\|^/|//|[\x00-\x1f]' -or (($entry.ExternalAttributes -shr 16) -band 0xf000) -eq 0xa000 -or
                ($entry.ExternalAttributes -band 0x400) -ne 0) { throw "Unsafe or linked archive entry: $name" }
            $parts = $name.TrimEnd('/').Split('/')
            if ($parts[0] -cne $Root -or ($parts.Count -eq 1 -and -not $directory)) { throw "Entry outside the expected archive root: $name" }
            $key = ''
            for ($i = 0; $i -lt $parts.Count; $i++) {
                $part = $parts[$i]
                if (-not $part -or $part -eq '.' -or $part -eq '..' -or $part -match '[<>:"|?*]|[ .]$' -or
                    $part -match '^(?i:CON|PRN|AUX|NUL|CLOCK\$|COM[1-9\u00b9\u00b2\u00b3]|LPT[1-9\u00b9\u00b2\u00b3])(?:\.|$)') { throw "Unsafe Windows archive name: $name" }
                $key = if ($key) { $key + '/' + $part } else { $part }
                $kind = if ($i -lt $parts.Count - 1 -or $directory) { 'directory' } else { 'file' }
                $explicit = $i -eq $parts.Count - 1
                if ($nodes.ContainsKey($key)) {
                    $seen = $nodes[$key]
                    if ($seen.Name -cne $key -or $seen.Kind -ne $kind -or ($explicit -and $seen.Explicit)) {
                        throw "Duplicate, case-colliding or file/directory-conflicting archive path: $name"
                    }
                    if ($explicit) { $seen.Explicit = $true }
                } else { $nodes.Add($key, [pscustomobject]@{Name=$key; Kind=$kind; Explicit=$explicit}) }
            }
            if ($directory -and $entry.Length -ne 0) { throw "Directory entry contains data: $name" }
            $total += $entry.Length
            if ($entry.Length -lt 0 -or $total -gt 4GB) { throw 'Archive expansion exceeds 4 GiB.' }
            $relative = $name.Substring($Root.Length).TrimStart('/').Replace('/', '\')
            $target = Join-Path (Join-Path $Stage $Root) $relative
            $final = if ($relative) { Join-Path $Destination $relative } else { $Destination }
            if ($target.Length -gt 240 -or $final.Length -gt 240) { throw "Expanded path exceeds 240 characters: $name" }
        }
        # Validate every name before creating any extracted file.
        foreach ($entry in $zip.Entries) {
            $target = Join-Path $Stage ($entry.FullName.Replace('/', '\'))
            if ($entry.FullName.EndsWith('/')) { [void][IO.Directory]::CreateDirectory($target); continue }
            [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($target))
            $inputStream = $entry.Open()
            $outputStream = $null
            try {
                $outputStream = [IO.File]::Open($target, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
                $buffer = New-Object byte[] 1048576
                [long]$written = 0
                while (($read = $inputStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                    $written += $read
                    if ($written -gt $entry.Length) { throw "Expanded entry exceeds declared length: $($entry.FullName)" }
                    $outputStream.Write($buffer, 0, $read)
                }
                if ($written -ne $entry.Length) { throw "Truncated archive entry: $($entry.FullName)" }
            } finally { if ($outputStream) { $outputStream.Dispose() }; $inputStream.Dispose() }
        }
    } finally { $zip.Dispose() }
}

function Remove-ReaderStage([string]$Stage, [string]$ExpectedParent) {
    $full = [IO.Path]::GetFullPath($Stage)
    if ([IO.Path]::GetDirectoryName($full) -cne $ExpectedParent -or
        [IO.Path]::GetFileName($full) -notmatch '^\.reader-stage-[0-9a-f]{32}$') { throw 'Refusing cleanup outside the owned staging path.' }
    Assert-ReaderAncestors $full
    $pending = New-Object 'Collections.Generic.Stack[string]'
    $pending.Push($full)
    while ($pending.Count) {
        foreach ($item in Get-ChildItem -LiteralPath $pending.Pop() -Force) {
            if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { throw 'Refusing cleanup of a redirected staging tree.' }
            if ($item.PSIsContainer) { $pending.Push($item.FullName) }
        }
    }
    Remove-Item -LiteralPath $full -Recurse -Force
}

function Invoke-ReaderInstall([string]$InstallPath, [string]$RuntimePath, [switch]$DownloadOnly) {
    $stageName = 'inputs'
    $stage = $null
    $ownedStage = $false
    $archiveCache = $null
    $verifiedArchive = $null
    try {
        if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) { throw 'Native Windows is required.' }
        $destination = Resolve-ReaderPath $InstallPath 'InstallPath' 80
        if (Test-Path -LiteralPath $destination) { throw "InstallPath already exists; choose a new version directory: $destination" }
        if (-not $DownloadOnly -or $RuntimePath) {
            $runtime = Resolve-ReaderPath $RuntimePath 'RuntimePath' 60
            if ($runtime -match '\s') { throw 'RuntimePath must not contain spaces.' }
            if ($destination.Equals($runtime, [StringComparison]::OrdinalIgnoreCase) -or
                $destination.StartsWith($runtime + '\', [StringComparison]::OrdinalIgnoreCase) -or
                $runtime.StartsWith($destination + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Installation and runtime paths must not overlap.' }
        }
        $stageName = 'metadata'
        $metadata = Read-ReaderMetadata (Join-Path (Split-Path $PSScriptRoot -Parent) 'release.json')
        $parent = [IO.Path]::GetDirectoryName($destination)
        [void][IO.Directory]::CreateDirectory($parent)
        Assert-ReaderAncestors $parent
        $stage = Join-Path $parent ('.reader-stage-' + [guid]::NewGuid().ToString('N'))
        if (Test-Path -LiteralPath $stage) { throw 'Staging path unexpectedly exists.' }
        [void][IO.Directory]::CreateDirectory($stage)
        $ownedStage = $true
        $stageName = 'archive cache'
        $archiveCache = Open-ReaderArchiveCache $parent $stage $destination $metadata
        $archive = $archiveCache.Archive
        $stageName = 'download'
        Write-Host "Downloading version $($metadata.version) from $($metadata.asset.url)"
        Write-Host "Expected program download: $($metadata.asset.bytes) bytes."
        Write-Host "Persistent program download: $archive"
        Invoke-ReaderDownload $metadata.asset.url $archive $metadata.asset.bytes $metadata.asset.sha256
        $stageName = 'archive verification'
        Write-Host 'Checking the program archive size and SHA-256.'
        if (-not (Test-Path -LiteralPath $archive -PathType Leaf)) { throw 'The download did not produce an archive.' }
        Assert-ReaderAncestors $archive
        # Hold the verified bytes against writers/deletion until ZipFile.OpenRead finishes.
        $verifiedArchive = [IO.File]::Open($archive, 'Open', 'Read', 'Read')
        Assert-ReaderOwnedFile $verifiedArchive $archive
        $actualBytes = $verifiedArchive.Length
        Write-Host "Received $actualBytes of $($metadata.asset.bytes) expected bytes."
        if ($actualBytes -ne [long]$metadata.asset.bytes) {
            throw "Downloaded archive size does not match release metadata. Received $actualBytes of $($metadata.asset.bytes) expected bytes."
        }
        if ((Get-ReaderStreamDigest $verifiedArchive) -ine $metadata.asset.sha256) { throw 'Downloaded archive SHA-256 does not match release metadata.' }
        $stageName = 'archive validation and extraction'
        Write-Host 'Program archive size and SHA-256 verified. Checking archive entries and extracting the program.'
        Expand-ReaderArchive $archive $stage $destination $metadata.asset.rootDirectory
        $verifiedArchive.Dispose(); $verifiedArchive = $null
        $stagedProduct = Join-Path $stage $metadata.asset.rootDirectory
        foreach ($required in @('YANG Paper Reader.exe', 'resources\backend\setup_runtime.cmd')) {
            $file = Join-Path $stagedProduct $required
            if (-not (Test-Path -LiteralPath $file -PathType Leaf) -or (Get-Item -LiteralPath $file).Length -eq 0) { throw "Required nonempty program file is missing: $required" }
        }
        $stageName = 'placement'
        Write-Host "Placing the verified program in $destination."
        Assert-ReaderAncestors $destination
        if (Test-Path -LiteralPath $destination) { throw 'InstallPath appeared during preparation; refusing to overwrite it.' }
        [IO.Directory]::Move($stagedProduct, $destination)
        try { Remove-ReaderArchiveCache $archiveCache }
        catch { Write-Warning "Program placement succeeded; owned archive cache cleanup failed at $($archiveCache.Root). $($_.Exception.Message)" }
        finally { $archiveCache.Lock.Dispose(); $archiveCache = $null }
        try { Remove-ReaderStage $stage $parent }
        catch { Write-Warning "Program placement succeeded; owned staging cleanup failed at $stage. $($_.Exception.Message)" }
        $ownedStage = $false
        if ($DownloadOnly) {
            Write-Host "Verified program placed at $destination. Runtime setup was not run; the app was not started."
            return [pscustomobject]@{ExitCode=0; Installed=$true; RuntimeSetup=$false; Path=$destination}
        }
        $stageName = 'runtime setup'
        Write-Host "Running pinned runtime setup for $runtime. The app will not be started."
        $code = Invoke-ReaderRuntime (Join-Path $destination 'resources\backend\setup_runtime.cmd') $runtime
        if ($code -ne 0) {
            Write-Host "FAILED [runtime setup]: exit code $code. Program remains at $destination; keep the setup output and named logs. Existing runtime data was not removed."
        } else { Write-Host "Runtime setup exited successfully. Program is at $destination; the app was not started." }
        return [pscustomobject]@{ExitCode=[int]$code; Installed=$true; RuntimeSetup=$true; Path=$destination}
    } catch {
        $reason = $_.Exception.Message
        if ($stageName -eq 'download') {
            $reason += ' Check the connection and run the same installer command again.'
        } elseif ($stageName -eq 'archive verification') {
            $reason += ' Check your connection and the version in the official release metadata, then run the same installer command again.'
        }
        throw "FAILED [$stageName]: $reason"
    } finally {
        if ($verifiedArchive) { $verifiedArchive.Dispose() }
        if ($archiveCache) { $archiveCache.Lock.Dispose() }
        if ($ownedStage) {
            try { Remove-ReaderStage $stage ([IO.Path]::GetDirectoryName($stage)) }
            catch { Write-Warning "Owned staging cleanup failed; retained $stage. $($_.Exception.Message)" }
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    try { $result = Invoke-ReaderInstall -InstallPath $InstallPath -RuntimePath $RuntimePath -DownloadOnly:$DownloadOnly; exit $result.ExitCode }
    catch { Write-Error $_ -ErrorAction Continue; exit 1 }
}
