[Setup]
AppName=ShockHub Client
AppVersion=1.01
AppPublisher=me0wg4ming
DefaultDirName={autopf}\ShockHubClient
DefaultGroupName=ShockHub Client
OutputDir=E:\shockhub_client\installer
OutputBaseFilename=ShockHubClient-Setup
SetupIconFile=E:\shockhub_client\shockhub_icon.ico
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
UninstallDisplayIcon={app}\shockhub_icon.ico

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional icons:"

[Files]
; Python embeddable (includes tkinter, tcl, site-packages)
Source: "E:\shockhub_client\python_embed\*"; DestDir: "{app}\python"; Flags: recursesubdirs createallsubdirs

; Main script and assets
Source: "E:\shockhub_client\client.py"; DestDir: "{userappdata}\ShockHubClient"; Flags: ignoreversion
Source: "E:\shockhub_client\shockhub_icon.ico"; DestDir: "{app}"
Source: "E:\shockhub_client\shockhub_logo.bmp"; DestDir: "{app}"

; Launcher
Source: "E:\shockhub_client\launcher.py"; DestDir: "{app}"

[Icons]
Name: "{group}\ShockHub Client"; Filename: "{app}\python\pythonw.exe"; Parameters: """{app}\launcher.py"""; WorkingDir: "{app}"; IconFilename: "{app}\shockhub_icon.ico"
Name: "{app}\ShockHub Client"; Filename: "{app}\python\pythonw.exe"; Parameters: """{app}\launcher.py"""; WorkingDir: "{app}"; IconFilename: "{app}\shockhub_icon.ico"
Name: "{group}\Uninstall ShockHub Client"; Filename: "{uninstallexe}"
Name: "{userdesktop}\ShockHub Client"; Filename: "{app}\python\pythonw.exe"; Parameters: """{app}\launcher.py"""; WorkingDir: "{app}"; IconFilename: "{app}\shockhub_icon.ico"; Tasks: desktopicon

[Code]
procedure FixPthFile();
var
  PthFile: String;
  Lines: TArrayOfString;
  Content: String;
  i: Integer;
  HasLib: Boolean;
begin
  PthFile := ExpandConstant('{app}\python\python314._pth');
  if not FileExists(PthFile) then
  begin
    // Try python311 as fallback
    PthFile := ExpandConstant('{app}\python\python311._pth');
    if not FileExists(PthFile) then Exit;
  end;

  LoadStringsFromFile(PthFile, Lines);
  HasLib := False;
  for i := 0 to GetArrayLength(Lines) - 1 do
    if Lines[i] = 'Lib' then HasLib := True;

  if not HasLib then
  begin
    Content := '';
    for i := 0 to GetArrayLength(Lines) - 1 do
      Content := Content + Lines[i] + #13#10;
    Content := Content + 'Lib' + #13#10 + 'Lib\site-packages' + #13#10;
    SaveStringToFile(PthFile, Content, False);
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
    FixPthFile();
end;

[Run]
Filename: "{app}\python\pythonw.exe"; Parameters: """{app}\launcher.py"""; WorkingDir: "{app}"; Description: "Launch ShockHub Client"; Flags: nowait postinstall skipifsilent
