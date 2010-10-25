[Setup]
AppName=FirmwareUploader
AppId=FirmwareUploader
AppVersion=1.0
AppPublisher=ruby.gruena.net
AppPublisherURL=http://github.com/weagruena/FirmwareUploader
AppCopyright=Copyright 2010 © ruby.gruena.net
DefaultDirName={pf}\FirmwareUploader
DefaultGroupName=FirmwareUploader
OutputDir=G:\_PROJ\Ruby\Ruby\HP_LJ_P1005\FirmwareUploader\dist
OutputBaseFilename=uploader_setup
SetupLogging=true
[Languages]
Name: english; MessagesFile: compiler:Default.isl; LicenseFile: G:\_PROJ\Ruby\Ruby\HP_LJ_P1005\FirmwareUploader\release\licenseE.txt; InfoAfterFile: G:\_PROJ\Ruby\Ruby\HP_LJ_P1005\FirmwareUploader\release\readmeE.txt
Name: german; MessagesFile: compiler:Languages\German.isl; LicenseFile: G:\_PROJ\Ruby\Ruby\HP_LJ_P1005\FirmwareUploader\release\licenseD.txt; InfoAfterFile: G:\_PROJ\Ruby\Ruby\HP_LJ_P1005\FirmwareUploader\release\readmeD.txt
[Files]
Source: release\config.txt; DestDir: {app}; Flags: ignoreversion
Source: release\sihpP1005.dl; DestDir: {app}; Flags: ignoreversion
Source: release\readmeD.txt; DestDir: {app}; Flags: ignoreversion; Languages: " german"
Source: release\readmeE.txt; DestDir: {app}; Flags: ignoreversion; Languages: english
Source: release\upload.exe; DestDir: {app}; Flags: ignoreversion
Source: release\test_server.exe; DestDir: {app}; Flags: ignoreversion; Components: test
[Icons]
Name: {group}\FirmwareUploader; Filename: {app}\upload.exe; IconIndex: 0; Flags: createonlyiffileexists
Name: {group}\Homepage; Filename: {app}\FirmwareUploader.url
Name: {group}\{cm:UninstallProgram, FirmwareUploader}; Filename: {uninstallexe}; Flags: createonlyiffileexists
Name: {userstartup}\FirmwareUploader; Filename: {app}\upload.exe; IconIndex: 0; Tasks: " autostart"; Flags: createonlyiffileexists; Components: 
Name: {commondesktop}\FirmwareUploader; Filename: {app}\upload.exe; IconIndex: 0; Flags: createonlyiffileexists; Tasks: desktopicon
[Tasks]
Name: desktopicon; Description: {cm:CreateDesktopIcon}; Flags: unchecked
Name: autostart; Description: Shortcut (Autostart); Flags: unchecked
[Components]
Name: program; Description: Main program; Flags: fixed; Types: custom compact full
Name: test; Description: Test server; Types: custom full
[UninstallDelete]
Name: {app}\config.txt; Type: files
Name: {app}\readmeD.txt; Type: files
Name: {app}\readmeE.txt; Type: files
Name: {app}\sihpP1005.dl; Type: files
Name: {app}\test_server.exe; Type: files
Name: {app}\upload.exe; Type: files
Type: files; Name: {app}\FirmwareUploader.url
Name: {app}; Type: dirifempty
[INI]
Filename: {app}\FirmwareUploader.url; Section: InternetShortcut; Key: URL; String: http://github.com/weagruena/FirmwareUploader/wiki
[Run]
Filename: {app}\config.txt; WorkingDir: {app}; Flags: shellexec skipifdoesntexist postinstall
