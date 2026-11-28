; SPDX-License-Identifier: AGPL-3.0-or-later
; Copyright (c) 2026 Hyeon-Ho Yang
; Independent Windows installer. The Reader application has separate terms.
;
; The Setup of YANG Paper Reader, built with Inno Setup 7:
;   ISCC.exe --define=AppVersion=<version> --define=ProductDir=<program folder>
;            --define=IconFile=<yang.ico> --define=InstalledSizeGB=<N> YANG_Paper_Reader.iss
; InstalledSizeGB is the size of the program and the runtime folder together, in GB of
; 1,073,741,824 bytes, rounded up. A test build also defines AppIdValue and AppTitle, so that
; it can never be taken for the real one.
; Silent use: /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SKIPRUNTIME=1 runs no runtime setup,
; starts nothing and shows no message box; each requirement check is written to the Setup log.

#ifndef AppIdValue
  #define AppIdValue "YANG.PaperReader"
#endif
#ifndef AppTitle
  #define AppTitle "YANG Paper Reader"
#endif
#ifndef AppVersion
  #define AppVersion "0.2.2"
#endif
#ifndef ProductDir
  #error Define ProductDir: the folder of the program to install.
#endif
#ifndef IconFile
  #error Define IconFile: the Reader's icon, resources\yang.ico.
#endif
#ifndef InstalledSizeGB
  #error Define InstalledSizeGB: the installed size of the program and the runtime, in GB.
#endif

[Setup]
AppId={#AppIdValue}
AppName={#AppTitle}
AppVersion={#AppVersion}
AppPublisher=Hyeon-Ho Yang
AppPublisherURL=https://hhyang95.com
AppSupportURL=https://github.com/HHYang95/YANG_Paper_Reader_Public
AppUpdatesURL=https://github.com/HHYang95/YANG_Paper_Reader_Public/releases
SetupArchitecture=x64
ArchitecturesAllowed=x64os
ArchitecturesInstallIn64BitMode=x64os
MinVersion=10.0.17763
PrivilegesRequired=lowest
DefaultDirName={autopf}\YANG_Paper_Reader
DefaultGroupName={#AppTitle}
DisableProgramGroupPage=yes
LicenseFile={#ProductDir}\LICENSE.txt
SetupIconFile={#IconFile}
UninstallDisplayIcon={app}\yang.ico
UninstallDisplayName={#AppTitle}
WizardStyle=modern
SetupLogging=yes
CloseApplicationsFilter=*.exe,*.dll,*.pyd,*.node
OutputBaseFilename=YANG_Paper_Reader_Setup_{#AppVersion}

[Files]
Source: "{#ProductDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#IconFile}"; DestDir: "{app}"; DestName: "yang.ico"; Flags: ignoreversion

[Icons]
Name: "{group}\{#AppTitle}"; Filename: "{app}\YANG Paper Reader.exe"; WorkingDir: "{app}"; IconFilename: "{app}\yang.ico"
Name: "{group}\Set Up Parsing Runtime"; Filename: "{cmd}"; Parameters: "{code:RuntimeCommand|/K}"; WorkingDir: "{app}"; Comment: "Sets up the parsing runtime again, for example after a failed setup."
Name: "{group}\User Manual"; Filename: "{app}\MANUAL.html"; Comment: "Opens the user manual in your web browser."
Name: "{group}\Install Guide"; Filename: "{app}\INSTALL_GUIDE.html"; Comment: "Opens the installation guide in your web browser."

[UninstallDelete]
; The runtime setup writes this file into the program folder; the runtime folder itself stays.
Type: files; Name: "{app}\resources\runtime\runtime.json*"

[Run]
Filename: "{cmd}"; Parameters: "{code:RuntimeCommand|/C}"; WorkingDir: "{app}"; StatusMsg: "Setting up the parsing runtime. The runtime setup downloads Python packages and models, which can take a long time."; Check: RuntimeWanted; BeforeInstall: RuntimeStarting; AfterInstall: RuntimeFinished; Flags: logoutput; OnLog: RuntimeLine

[Code]
const
  RuntimeDefault = 'C:\YANG_Paper_Reader_Runtime';
  { The default of earlier versions, and the marker file the runtime setup writes into a runtime folder. }
  RuntimeEarlier = 'C:\Reader_Runtime';
  RuntimeMarker = 'yang-paper-reader-runtime.txt';
  NeededGB = {#InstalledSizeGB};
  BytesPerGB = 1073741824;
  DriveFixed = 3;
  PythonLink = 'https://www.python.org/downloads/release/python-31210/';
  DriverLink = 'https://www.nvidia.com/en-us/drivers/';
  ClaudeLink = 'https://code.claude.com/docs/en/setup#install-on-native-windows';
  CodexLink = 'https://developers.openai.com/codex/cli/';
  PythonProbe = ' -c "import sys;print(sys.version.split()[0],sys.maxsize.bit_length()+1)"';

var
  RuntimePage: TInputDirWizardPage;
  CheckPage: TWizardPage;
  RowText: array[0..3] of TNewStaticText;
  RowLink: array[0..3] of TNewLinkLabel;
  RuntimeBox: TNewCheckBox;
  CheckNote: TNewStaticText;
  ResultMemo: TNewMemo;
  Checked, BoxSet, PythonOk, GpuOk: Boolean;
  RuntimeState, LastLine, FailedReason: String;

function GetDriveType(RootPathName: String): Integer;
  external 'GetDriveTypeW@kernel32.dll stdcall';

function SkipRuntime: Boolean;
begin
  Result := ExpandConstant('{param:SKIPRUNTIME|0}') = '1';
end;

function RuntimeDir(Param: String): String;
begin
  Result := Trim(RuntimePage.Values[0]);
  StringChangeEx(Result, '/', '\', True);
  Result := RemoveBackslashUnlessRoot(Result);
end;

{ cmd /C or /K with the whole command in one more pair of quotes, which cmd removes. }
function RuntimeCommand(Param: String): String;
begin
  Result := Param + ' ""' + ExpandConstant('{app}') + '\resources\backend\setup_runtime.cmd" "' + RuntimeDir('') + '""';
end;

{ The bounds of the runtime folder: an absolute path on a local fixed
  drive, at most 60 characters, no spaces, no shell characters, no reserved or empty names,
  no linked folder on the way, and apart from the program folder. }
function IsReservedName(const Part: String): Boolean;
var
  Base: String;
begin
  Base := Uppercase(Part);
  if Pos('.', Base) > 0 then
    Base := Copy(Base, 1, Pos('.', Base) - 1);
  Result := (Base = 'CON') or (Base = 'PRN') or (Base = 'AUX') or (Base = 'NUL') or (Base = 'CLOCK$');
  if (Length(Base) = 4) and ((Copy(Base, 1, 3) = 'COM') or (Copy(Base, 1, 3) = 'LPT')) then
    if Pos(Copy(Base, 4, 1), '123456789' + #$B9 + #$B2 + #$B3) > 0 then
      Result := True;
end;

function RuntimeFolderProblem(const Dir: String): String;
var
  I: Integer;
  C, Rest, Part, Up, AppDir: String;
  Rec: TFindRec;
  Attributes: Cardinal;
begin
  Result := '';
  if (Length(Dir) < 3) or (Copy(Dir, 2, 2) <> ':\') or
     (Pos(Uppercase(Copy(Dir, 1, 1)), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ') = 0) then
  begin
    Result := 'Enter a full folder path that starts with a drive letter, such as ' + RuntimeDefault + '.';
    Exit;
  end;
  for I := 1 to Length(Dir) do
  begin
    C := Copy(Dir, I, 1);
    if (C = ' ') or (Ord(C[1]) = $A0) or (Ord(C[1]) = $3000) then
    begin
      Result := 'The runtime folder path must not contain spaces.';
      Exit;
    end;
    if (Ord(C[1]) < 32) or (Pos(C, '<>"|?*%&!^;`()') > 0) then
    begin
      Result := 'The runtime folder path must not contain any of these characters: < > " | ? * % & ! ^ ; ` ( )';
      Exit;
    end;
  end;
  if Length(Dir) > 60 then
  begin
    Result := 'The runtime folder path must be at most 60 characters long.';
    Exit;
  end;
  Rest := Copy(Dir, 4, Length(Dir));
  if Rest = '' then
  begin
    Result := 'Choose a folder, not the root of a drive.';
    Exit;
  end;
  Rest := Rest + '\';
  while Rest <> '' do
  begin
    Part := Copy(Rest, 1, Pos('\', Rest) - 1);
    Delete(Rest, 1, Pos('\', Rest));
    if (Part = '') or (Part = '.') or (Part = '..') or (Copy(Part, Length(Part), 1) = '.') or
       (Pos(':', Part) > 0) or IsReservedName(Part) then
    begin
      Result := 'The runtime folder path contains a folder name that Windows does not allow.';
      Exit;
    end;
  end;
  if GetDriveType(Copy(Dir, 1, 3)) <> DriveFixed then
  begin
    Result := 'The runtime folder must be on a local fixed drive.';
    Exit;
  end;
  AppDir := Uppercase(RemoveBackslashUnlessRoot(WizardDirValue));
  Up := Uppercase(Dir);
  if (Up = AppDir) or (Pos(AppDir + '\', Up) = 1) or (Pos(Up + '\', AppDir) = 1) then
  begin
    Result := 'The runtime folder and the program folder must be separate, and neither may lie inside the other.';
    Exit;
  end;
  Up := Dir;
  while Length(Up) > 3 do
  begin
    if FindFirst(Up, Rec) then
    begin
      Attributes := Rec.Attributes;
      FindClose(Rec);
      if (Attributes and $400) <> 0 then
      begin
        Result := 'The runtime folder path must not pass through a linked folder.';
        Exit;
      end;
      if (Up <> Dir) and ((Attributes and $10) = 0) then
      begin
        Result := 'A part of the runtime folder path is a file, not a folder.';
        Exit;
      end;
    end;
    Up := ExtractFileDir(Up);
  end;
end;

{ The requirement checks. Python and the AI tools are looked for where the runtime setup and the
  Reader look for them; the GPU row reads nvidia-smi, which the NVIDIA driver installs; the disk row
  reads the drive of the runtime folder. Each result is written to the Setup log, and none stops
  the installation. }
function RunLine(const Params: String; var Line: String): Boolean;
var
  Code: Integer;
  Output: TExecOutput;
begin
  Line := '';
  Result := False;
  if ExecAndCaptureOutput(ExpandConstant('{cmd}'), Params, '', SW_HIDE, ewWaitUntilTerminated, Code, Output) then
    if (Code = 0) and (GetArrayLength(Output.StdOut) > 0) then
    begin
      Line := Trim(Output.StdOut[0]);
      Result := Line <> '';
    end;
end;

function NextField(var Line: String): String;
begin
  if Pos(',', Line) > 0 then
  begin
    Result := Trim(Copy(Line, 1, Pos(',', Line) - 1));
    Delete(Line, 1, Pos(',', Line));
  end
  else
  begin
    Result := Trim(Line);
    Line := '';
  end;
end;

function LeadingNumber(const S: String): Integer;
begin
  if Pos('.', S) > 0 then
    Result := StrToIntDef(Copy(S, 1, Pos('.', S) - 1), 0)
  else
    Result := StrToIntDef(S, 0);
end;

function TrailingNumber(const S: String): Integer;
begin
  if Pos('.', S) > 0 then
    Result := StrToIntDef(Copy(S, Pos('.', S) + 1, Length(S)), 0)
  else
    Result := 0;
end;

procedure ShowRow(Index: Integer; const Text, Link: String);
begin
  RowText[Index].Caption := Text;
  RowLink[Index].Caption := Link;
  RowLink[Index].Visible := Link <> '';
  Log('Requirement check: ' + Text);
end;

procedure CheckPython;
var
  Line, Version, Bits: String;
begin
  { setup_runtime.cmd looks for "py -3.12", then for "python". }
  if not RunLine('/C py -3.12' + PythonProbe, Line) then
    RunLine('/C python' + PythonProbe, Line);
  Version := Line;
  Bits := '';
  if Pos(' ', Line) > 0 then
  begin
    Version := Copy(Line, 1, Pos(' ', Line) - 1);
    Bits := Copy(Line, Pos(' ', Line) + 1, Length(Line));
  end;
  PythonOk := (Pos('3.12.', Version) = 1) and (Bits = '64');
  if PythonOk then
    ShowRow(0, 'Python 3.12, 64-bit: found Python ' + Version + '.', '')
  else if Line <> '' then
    ShowRow(0, 'Python 3.12, 64-bit: found Python ' + Version + ' (' + Bits + '-bit), but parsing needs Python 3.12, 64-bit.',
      '<a href="' + PythonLink + '">Get Python 3.12 (64-bit) from python.org</a>')
  else
    ShowRow(0, 'Python 3.12, 64-bit: not found.', '<a href="' + PythonLink + '">Get Python 3.12 (64-bit) from python.org</a>');
end;

procedure CheckGpu;
var
  Line, Name, Driver, Memory, Capability, Text: String;
  DriverOk, CapabilityOk: Boolean;
begin
  { Parsing runs on the first NVIDIA GPU, so the first line of nvidia-smi is read. }
  GpuOk := False;
  Text := 'NVIDIA GPU of compute capability 8.0 or higher, with driver 576.02 or newer: ';
  if not RunLine('/C nvidia-smi --query-gpu=name,driver_version,memory.total,compute_cap --format=csv,noheader,nounits', Line) then
  begin
    ShowRow(1, Text + 'nvidia-smi, which the NVIDIA driver installs, did not report an NVIDIA GPU.',
      '<a href="' + DriverLink + '">Get the NVIDIA driver</a>');
    Exit;
  end;
  Name := NextField(Line);
  Driver := NextField(Line);
  Memory := NextField(Line);
  Capability := NextField(Line);
  DriverOk := (LeadingNumber(Driver) > 576) or ((LeadingNumber(Driver) = 576) and (TrailingNumber(Driver) >= 2));
  CapabilityOk := LeadingNumber(Capability) >= 8;
  GpuOk := DriverOk and CapabilityOk;
  Text := Text + 'nvidia-smi reports ' + Name + ', compute capability ' + Capability + ', driver ' + Driver +
    ', ' + IntToStr((StrToIntDef(Memory, 0) + 512) div 1024) + ' GB of memory.';
  if not CapabilityOk then
    Text := Text + ' This GPU cannot run the parser.';
  if not DriverOk then
    ShowRow(1, Text + ' Update the driver.', '<a href="' + DriverLink + '">Get the NVIDIA driver</a>')
  else
    ShowRow(1, Text, '');
end;

function CodexNpmDirs(const Prefix: String): String;
var
  Scope, Target: String;
begin
  Scope := Prefix + '\node_modules\@openai';
  Target := '\vendor\x86_64-pc-windows-msvc';
  Result := Scope + '\codex\node_modules\@openai\codex-win32-x64' + Target + '\bin;' +
    Scope + '\codex-win32-x64' + Target + '\bin;' + Scope + '\codex' + Target + '\bin;' +
    Scope + '\codex' + Target + '\codex;';
end;

procedure CheckAi;
var
  Home, Npm, Rest, Folder, PathDirs, CodexDirs, Claude, Codex, Found: String;
  Count: Integer;
begin
  { The places the Reader looks: each tool's installer place, the npm global package, then each PATH folder. }
  Home := GetEnv('USERPROFILE');
  Npm := GetEnv('APPDATA') + '\npm';
  PathDirs := '';
  CodexDirs := '';
  Rest := GetEnv('PATH') + ';';
  Count := 0;
  while (Rest <> '') and (Count < 64) do
  begin
    Folder := Trim(Copy(Rest, 1, Pos(';', Rest) - 1));
    Delete(Rest, 1, Pos(';', Rest));
    StringChangeEx(Folder, '"', '', True);
    if (Copy(Folder, 2, 2) = ':\') or (Copy(Folder, 1, 2) = '\\') then
    begin
      PathDirs := PathDirs + Folder + ';';
      CodexDirs := CodexDirs + CodexNpmDirs(Folder);
      Count := Count + 1;
    end;
  end;
  Claude := FileSearch('claude.exe', Npm + '\node_modules\@anthropic-ai\claude-code\bin;' + Home + '\.local\bin;' + PathDirs);
  Codex := FileSearch('codex.exe', GetEnv('LOCALAPPDATA') + '\Programs\OpenAI\Codex\bin;' +
    Npm + '\node_modules\@openai\codex\vendor\x86_64-pc-windows-msvc\codex;' + PathDirs + CodexNpmDirs(Npm) + CodexDirs);
  if (Claude <> '') and (Codex <> '') then
    Found := 'Claude Code and Codex'
  else if Claude <> '' then
    Found := 'Claude Code'
  else
    Found := 'Codex';
  if (Claude = '') and (Codex = '') then
    ShowRow(2, 'Claude Code 2.1.330 or newer, or Codex 0.171.0 or newer: neither was found. AI requests need one of them, signed in with your own account.',
      '<a href="' + ClaudeLink + '">Get Claude Code</a>   <a href="' + CodexLink + '">Get Codex</a>')
  else
    ShowRow(2, 'Claude Code 2.1.330 or newer, or Codex 0.171.0 or newer: found ' + Found + '. The Reader checks the version in AI Settings.', '');
end;

procedure CheckDisk;
var
  Drive: String;
  Free, Total, Needed: Int64;
begin
  Drive := ExtractFileDrive(RuntimeDir(''));
  if not GetSpaceOnDisk64(Drive + '\', Free, Total) then
  begin
    ShowRow(3, 'Free disk space: Setup could not read the free space of drive ' + Drive + ', the drive of the runtime folder.', '');
    Exit;
  end;
  Needed := NeededGB;
  Needed := Needed * BytesPerGB;
  if Free >= Needed then
    ShowRow(3, 'Free disk space: ' + IntToStr(Free div BytesPerGB) + ' GB free on drive ' + Drive +
      ', the drive of the runtime folder. The program and the parsing runtime need about ' + IntToStr(NeededGB) + ' GB.', '')
  else
    ShowRow(3, 'Free disk space: ' + IntToStr(Free div BytesPerGB) + ' GB free on drive ' + Drive +
      ', the drive of the runtime folder, but the program and the parsing runtime need about ' + IntToStr(NeededGB) +
      ' GB. Free up space, or go back and choose a runtime folder on another drive.', '');
end;

procedure LayoutChecks;
var
  I, Top: Integer;
begin
  Top := 0;
  for I := 0 to 3 do
  begin
    RowText[I].Top := Top;
    RowText[I].AdjustHeight;
    Top := Top + RowText[I].Height + ScaleY(2);
    if RowLink[I].Visible then
    begin
      RowLink[I].Top := Top;
      Top := Top + RowLink[I].Height + ScaleY(2);
    end;
    Top := Top + ScaleY(6);
  end;
  RuntimeBox.Top := Top;
  Top := Top + RuntimeBox.Height + ScaleY(4);
  CheckNote.Top := Top;
  CheckNote.AdjustHeight;
end;

procedure RunChecks;
begin
  CheckPython;
  CheckGpu;
  CheckAi;
  CheckDisk;
  if not BoxSet then
  begin
    RuntimeBox.Checked := PythonOk and GpuOk and not SkipRuntime;
    BoxSet := True;
  end;
  Checked := True;
  LayoutChecks;
end;

procedure LinkClick(Sender: TObject; const Link: String; LinkType: TSysLinkType);
var
  ErrorCode: Integer;
begin
  ShellExec('open', Link, '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
end;

{ The runtime setup at the end: today's setup_runtime.cmd, its lines shown and logged, its last line read. }
function RuntimeWanted: Boolean;
begin
  Result := RuntimeBox.Checked and not SkipRuntime;
end;

procedure RuntimeStarting;
begin
  RuntimeState := 'failed';
  LastLine := '';
  FailedReason := '';
  Log('Runtime setup: started for ' + RuntimeDir('') + '.');
end;

procedure RuntimeLine(const S: String; const Error, FirstLine: Boolean);
var
  Line: String;
  Step: Integer;
begin
  Line := Trim(S);
  if Line = '' then
    Exit;
  Log('Runtime setup: ' + Line);
  LastLine := Line;
  { A step that fails ends its own line: '[n/7] <step> ... FAILED: <reason>'. }
  if Pos('FAILED: ', Line) > 0 then
    FailedReason := Line;
  WizardForm.FilenameLabel.Caption := Line;
  if (Pos('[', Line) = 1) and (Copy(Line, 3, 3) = '/7]') then
  begin
    Step := StrToIntDef(Copy(Line, 2, 1), 0);
    if (Step >= 1) and (Step < 7) then
      WizardForm.StatusLabel.Caption := 'Setting up the parsing runtime: step ' + IntToStr(Step + 1) + ' of 7. This can take a long time.';
  end;
end;

procedure RuntimeFinished;
begin
  if LastLine = 'Runtime ready.' then
    RuntimeState := 'ready';
  Log('Runtime setup: finished, ' + RuntimeState + '.');
end;

{ What to do stands in the page's text; the runtime setup's last lines and the log places, which can
  be long, stand below it in a read-only box that scrolls. }
procedure ShowResult;
var
  Text, Details: String;
begin
  Details := '';
  if RuntimeState = 'ready' then
    Text := '{#AppTitle} is installed, and its parsing runtime is ready.' + #13#10#13#10 +
      'Start the Reader from the Start menu.'
  else if RuntimeState = 'failed' then
  begin
    Text := '{#AppTitle} is installed, but the parsing runtime is not ready.' + #13#10#13#10 +
      'After you fix the cause shown below, run Set Up Parsing Runtime from the Start menu, or run this Setup again.';
    Details := 'The runtime setup ended with:' + #13#10;
    if FailedReason <> '' then
      Details := Details + FailedReason + #13#10;
    Details := Details + LastLine;
    if DirExists(AddBackslash(RuntimeDir('')) + 'logs') then
      Details := Details + #13#10#13#10 + 'The runtime setup''s logs are in ' + AddBackslash(RuntimeDir('')) + 'logs.';
    if ExpandConstant('{log}') <> '' then
      Details := Details + #13#10#13#10 + 'The log of this Setup is ' + ExpandConstant('{log}') + '.';
  end
  else
    Text := '{#AppTitle} is installed. This run did not set up the parsing runtime. Unless the runtime of this installation was set up before, the Reader cannot parse papers yet.' + #13#10#13#10 +
      'To set it up, run Set Up Parsing Runtime from the Start menu, or run this Setup again. It needs Python 3.12 (64-bit) and the NVIDIA driver.';
  WizardForm.FinishedLabel.Caption := Text;
  WizardForm.FinishedLabel.AdjustHeight;
  if Details <> '' then
  begin
    ResultMemo.Left := WizardForm.FinishedLabel.Left;
    ResultMemo.Top := WizardForm.FinishedLabel.Top + WizardForm.FinishedLabel.Height + ScaleY(8);
    ResultMemo.Width := WizardForm.FinishedLabel.Width;
    ResultMemo.Height := WizardForm.FinishedPage.Height - ResultMemo.Top - ScaleY(8);
    ResultMemo.Text := Details;
    ResultMemo.Visible := True;
  end;
end;

{ The runtime folder of an earlier version at its default place is offered first, so that it is not downloaded again. }
function DefaultRuntimeFolder: String;
begin
  if FileExists(RuntimeEarlier + '\' + RuntimeMarker) then
    Result := RuntimeEarlier
  else
    Result := RuntimeDefault;
end;

procedure InitializeWizard;
var
  I: Integer;
begin
  RuntimeState := 'not run';
  RuntimePage := CreateInputDirPage(wpSelectDir, 'Parsing Runtime Folder', 'Where should Setup put the parsing runtime?',
    'Parsing uses a runtime: the Python packages and models that the runtime setup downloads into a folder of its own. ' +
    'Choose a new or empty folder, or the runtime folder of an earlier installation, on a local drive (not a network or removable drive). ' +
    'The path can have at most 60 characters and no spaces. Uninstalling the Reader leaves this folder in place.',
    False, '');
  RuntimePage.Add('');
  RuntimePage.Values[0] := GetPreviousData('RuntimeFolder', DefaultRuntimeFolder);
  CheckPage := CreateCustomPage(RuntimePage.ID, 'Requirements',
    'Setup checked what {#AppTitle} needs on this PC. Nothing here stops the installation.');
  for I := 0 to 3 do
  begin
    RowText[I] := TNewStaticText.Create(CheckPage);
    RowText[I].Parent := CheckPage.Surface;
    RowText[I].AutoSize := False;
    RowText[I].WordWrap := True;
    RowText[I].Width := CheckPage.SurfaceWidth;
    RowLink[I] := TNewLinkLabel.Create(CheckPage);
    RowLink[I].Parent := CheckPage.Surface;
    RowLink[I].Left := ScaleX(16);
    RowLink[I].OnLinkClick := @LinkClick;
    RowLink[I].Visible := False;
  end;
  RuntimeBox := TNewCheckBox.Create(CheckPage);
  RuntimeBox.Parent := CheckPage.Surface;
  RuntimeBox.Width := CheckPage.SurfaceWidth;
  RuntimeBox.Caption := 'Set up the parsing runtime at the end of Setup';
  CheckNote := TNewStaticText.Create(CheckPage);
  CheckNote.Parent := CheckPage.Surface;
  CheckNote.AutoSize := False;
  CheckNote.WordWrap := True;
  CheckNote.Width := CheckPage.SurfaceWidth;
  CheckNote.Caption := 'Starts checked only if Python and GPU checks pass. ' +
    'Check to run runtime setup when Setup finishes, or use ' +
    'Start > Set Up Parsing Runtime later. Requirements still apply.';
  ResultMemo := TNewMemo.Create(WizardForm);
  ResultMemo.Parent := WizardForm.FinishedPage;
  ResultMemo.ReadOnly := True;
  ResultMemo.ScrollBars := ssVertical;
  ResultMemo.Visible := False;
end;

procedure RegisterPreviousData(PreviousDataKey: Integer);
begin
  SetPreviousData(PreviousDataKey, 'RuntimeFolder', RuntimeDir(''));
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  Problem: String;
begin
  Result := True;
  if CurPageID = RuntimePage.ID then
  begin
    RuntimePage.Values[0] := RuntimeDir('');
    Problem := RuntimeFolderProblem(RuntimeDir(''));
    if Problem <> '' then
    begin
      Log('Runtime folder refused: ' + Problem);
      SuppressibleMsgBox(Problem, mbError, MB_OK, IDOK);
      Result := False;
    end;
  end;
end;

{ The Ready page's summary: the program folder as Inno gives it, then the runtime folder and whether
  the runtime setup runs, on a first install and on a run over an earlier one alike. }
function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo,
  MemoGroupInfo, MemoTasksInfo: String): String;
begin
  Result := '';
  if MemoDirInfo <> '' then
    Result := MemoDirInfo + NewLine + NewLine;
  if MemoGroupInfo <> '' then
    Result := Result + MemoGroupInfo + NewLine + NewLine;
  Result := Result + 'Parsing runtime folder:' + NewLine + Space + RuntimeDir('') + NewLine + NewLine +
    'Runtime setup:' + NewLine + Space;
  if RuntimeWanted then
    Result := Result + 'Runs at the end of Setup.'
  else
    Result := Result + 'Does not run.';
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = CheckPage.ID then
    RunChecks
  else if CurPageID = wpFinished then
    ShowResult;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssInstall then
  begin
    if not Checked then
      RunChecks;
    if RuntimeWanted then
      Log('Runtime folder: ' + RuntimeDir('') + '. The runtime setup runs at the end.')
    else
      Log('Runtime folder: ' + RuntimeDir('') + '. The runtime setup does not run.');
    Log('Set Up Parsing Runtime runs: ' + ExpandConstant('{cmd}') + ' ' + RuntimeCommand('/K'));
  end;
end;
