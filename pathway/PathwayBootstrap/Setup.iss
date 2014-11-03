#define MyAppSetupName 'PathwayBootstrap'
#define MyAppVersion '2.0'
#define IsExternal ""

[Setup]
AppName={#MyAppSetupName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppSetupName} {#MyAppVersion}
AppCopyright=Copyright © SIL International 2007-2014
VersionInfoVersion={#MyAppVersion}
VersionInfoCompany=SIL International
AppPublisher=SIL International
;AppPublisherURL=http://...
;AppSupportURL=http://...
;AppUpdatesURL=http://...
AppID={{F768F6BA-F164-4599-BC26-DCCFC2F76855}
OutputBaseFilename={#MyAppSetupName}-{#MyAppVersion}
DefaultGroupName={#MyAppSetupName}
DefaultDirName={pf32}\SIL\Pathway7
DisableDirPage=yes
;DefaultDirName={pf}\{#MyAppSetupName}
;UninstallDisplayIcon={app}\PathwayBootstrap.exe
OutputDir=bin
;SourceDir=.
AllowNoIcons=yes
;SetupIconFile=PathwayBootstrapIcon
SolidCompression=yes
WizardImageFile=LeftSideBanner.bmp
WizardSmallImageFile=sil.bmp
;MinVersion default value: "0,5.0 (Windows 2000+) if Unicode Inno Setup, else 4.0,4.0 (Windows 95+)"
;MinVersion=0,5.0
PrivilegesRequired=admin
ArchitecturesAllowed=x86 x64 ia64
ArchitecturesInstallIn64BitMode=x64 ia64


[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "de"; MessagesFile: "compiler:Languages\German.isl"


[Registry]
Root: HKCU; Subkey: "Software\My Company"; Flags: uninsdeletekeyifempty
Root: HKCU; Subkey: "Software\My Company\Pathway"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\My Company\Pathway\Settings"; ValueType: string; ValueName: "Name"; ValueData: "{code:GetUser|Name}"
Root: HKCU; Subkey: "Software\My Company\Pathway\Settings"; ValueType: string; ValueName: "Company"; ValueData: "{code:GetUser|Company}"

#include "scripts\silproducts.iss"
#include "scripts\products\winversion.iss"
#include "scripts\products\fileversion.iss"
  

[Code]
function InitializeSetup(): Boolean;
var
oldVersion: String;
uninstaller: String;
ErrorCode: Integer;
begin

if RegKeyExists(HKEY_LOCAL_MACHINE,
'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{F768F6BA-F164-4599-BC26-DCCFC2F76855}_is1') then
begin
RegQueryStringValue(HKEY_LOCAL_MACHINE,
'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{F768F6BA-F164-4599-BC26-DCCFC2F76855}_is1',
'DisplayVersion', oldVersion);
if (CompareVersion(oldVersion, '10.0.0.4006') < 0) then
begin
if MsgBox('Version ' + oldVersion + ' of Code Beautifier Collection is already installed. Continue to use this old version?',
mbConfirmation, MB_YESNO) = IDYES then
begin
Result := False;
end
else
begin
RegQueryStringValue(HKEY_LOCAL_MACHINE,
'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{F768F6BA-F164-4599-BC26-DCCFC2F76855}_is1',
'UninstallString', uninstaller);
ShellExec('runas', uninstaller, '/SILENT', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode);
Result := True;
end;
end
else
begin
MsgBox('Version ' + oldVersion + ' of Code Beautifier Collection is already installed. This installer will exit.',
mbInformation, MB_OK);
Result :=True;
end;
end
else
begin
Result := True;
end;
end;