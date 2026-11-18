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

function Invoke-ReaderDownload([string]$Url, [string]$Destination) {
    Invoke-WebRequest -UseBasicParsing -Uri $Url -OutFile $Destination
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
        $archive = Join-Path $stage 'download.zip'
        $stageName = 'download'
        Write-Host "Downloading version $($metadata.version) from $($metadata.asset.url)"
        Invoke-ReaderDownload $metadata.asset.url $archive
        $stageName = 'archive verification'
        if (-not (Test-Path -LiteralPath $archive -PathType Leaf)) { throw 'The download did not produce an archive.' }
        Assert-ReaderAncestors $archive
        if ((Get-Item -LiteralPath $archive).Length -ne [long]$metadata.asset.bytes) { throw 'Downloaded archive size does not match release metadata.' }
        if ((Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash -ine $metadata.asset.sha256) { throw 'Downloaded archive SHA-256 does not match release metadata.' }
        $stageName = 'archive validation and extraction'
        Expand-ReaderArchive $archive $stage $destination $metadata.asset.rootDirectory
        $stagedProduct = Join-Path $stage $metadata.asset.rootDirectory
        foreach ($required in @('YANG Paper Reader.exe', 'resources\backend\setup_runtime.cmd')) {
            $file = Join-Path $stagedProduct $required
            if (-not (Test-Path -LiteralPath $file -PathType Leaf) -or (Get-Item -LiteralPath $file).Length -eq 0) { throw "Required nonempty program file is missing: $required" }
        }
        $stageName = 'placement'
        Assert-ReaderAncestors $destination
        if (Test-Path -LiteralPath $destination) { throw 'InstallPath appeared during preparation; refusing to overwrite it.' }
        [IO.Directory]::Move($stagedProduct, $destination)
        Remove-ReaderStage $stage $parent
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
        throw "FAILED [$stageName]: $($_.Exception.Message)"
    } finally {
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
