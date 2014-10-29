#include "isxdl\isxdl.iss"
#include "products\dotnetfxversion.iss"

#define MyAppURL "http://pathway.sil.org/wp-content/uploads/"
#define StableExeName "SetupPw7BTE-1.12.0.4302.msi"
#define LatestExeName "SetupPw7BTETesting-1.12.0.4302.msi"

[Files]
Source: "scripts\PathwayLogo.bmp"; DestDir: "{app}"; DestName: "PathwayLogo.bmp";
Source: "scripts\License.rtf"; DestDir: "{app}"; DestName: "License.rtf";
[CustomMessages]
DependenciesDir=MyProgramDependencies

en.depdownload_msg=The following applications are required before setup can continue:%n%n%1%nDownload and install now?
de.depdownload_msg=Die folgenden Programme werden benötigt bevor das Setup fortfahren kann:%n%n%1%nJetzt downloaden und installieren?

en.depdownload_memo_title=Download dependencies
de.depdownload_memo_title=Abhängigkeiten downloaden

en.depinstall_memo_title=Install dependencies
de.depinstall_memo_title=Abhängigkeiten installieren

en.depinstall_title=Installing dependencies
de.depinstall_title=Installiere Abhängigkeiten

en.depinstall_description=Please wait while Setup installs dependencies on your computer.
de.depinstall_description=Warten Sie bitte während Abhängigkeiten auf Ihrem Computer installiert wird.

en.depinstall_status=Installing %1...
de.depinstall_status=Installiere %1...

en.depinstall_missing=%1 must be installed before setup can continue. Please install %1 and run Setup again.
de.depinstall_missing=%1 muss installiert werden bevor das Setup fortfahren kann. Bitte installieren Sie %1 und starten Sie das Setup erneut.

en.depinstall_error=An error occured while installing the dependencies. Please restart the computer and run the setup again or install the following dependencies manually:%n
de.depinstall_error=Ein Fehler ist während der Installation der Abghängigkeiten aufgetreten. Bitte starten Sie den Computer neu und führen Sie das Setup erneut aus oder installieren Sie die folgenden Abhängigkeiten per Hand:%n

en.isxdl_langfile=
de.isxdl_langfile=german2.ini

dotnetfx20_title=.NET Framework 2.0
dotnetfx20_size=23 MB
Libreoffice_title=Libre office
Libreoffice_size=214 MB
jre6_title=Java Runtime Environment 6
jre6_size=10 MB
epub_title=Calibre Epub file viewer  
epub_size=59.3 MB
stable_title=Pathway Stable  
stable_size=18 MB
latest_title=Pathway Latest  
latest_size=20 MB
pdfViewer_title=Xchange PdfViewer  
pdfViewer_size=16.1 MB
princeXml_title=PrinceXML
princeXml_size=10.9 MB
xelatex_title=Xelatex
xelatex_size=96.4 MB


[Code]

type
	TProduct = record
		File: String;
		Title: String;
		Parameters: String;
		InstallClean : boolean;
		MustRebootAfter : boolean;
	end;

	InstallResult = (InstallSuccessful, InstallRebootRequired, InstallError);

  var
	installMemo, downloadMemo, downloadMessage: string;
	products: array of TProduct;
	delayedReboot: boolean;
	DependencyPage: TOutputProgressWizardPage;
  missingDeps: boolean;

  const
	dotnetfx20_url = 'http://download.microsoft.com/download/5/6/7/567758a3-759e-473e-bf8f-52154438565a/dotnetfx.exe';
	dotnetfx20_url_x64 = 'http://download.microsoft.com/download/a/3/f/a3f1bf98-18f3-4036-9b68-8e6de530ce0a/NetFx64.exe';
	dotnetfx20_url_ia64 = 'http://download.microsoft.com/download/f/8/6/f86148a4-e8f7-4d08-a484-b4107f238728/NetFx64.exe';
  Libreoffice_url = 'http://download.documentfoundation.org/libreoffice/stable/4.3.2/win/x86/LibreOffice_4.3.2_Win_x86.msi';
  princeXml = 'http://www.princexml.com/download/prince-9.0r5-setup.exe';
  java_url = 'http://javadl.sun.com/webapps/download/AutoDL?BundleId=98426';
  java64bit_url = 'http://javadl.sun.com/webapps/download/AutoDL?BundleId=98428';
  jre6_url = 'http://javadl.sun.com/webapps/download/AutoDL?BundleId=32267';
  epub_url = 'http://status.calibre-ebook.com/dist/win32';
  pdfViewer_url = 'http://34e34375d0b7c22eafcf-c0a4be9b34fe09958cbea1670de70e9b.r87.cf1.rackcdn.com/PDFXVwer.exe';
  princeXml_url = 'http://www.princexml.com/download/prince-9.0r5-setup.exe';
  xelatex_url = 'http://pathway.sil.org/wp-content/sprint/SetupXeLaTeXTesting-1.10.0.3926.msi';
  
  stable_url='{#MyAppURL}/{#StableExeName}';
  Latest_url='{#MyAppURL}/{#LatestExeName}';
procedure AddProduct(FileName, Parameters, Title, Size, URL: string; InstallClean : boolean; MustRebootAfter : boolean);
var
	path: string;
	i: Integer;
begin
	installMemo := installMemo + '%1' + Title + #13;

	path := ExpandConstant('{src}{\}') + CustomMessage('DependenciesDir') + '\' + FileName;
	if not FileExists(path) then begin
		path := ExpandConstant('{tmp}{\}') + FileName;

		isxdl_AddFile(URL, path);

		downloadMemo := downloadMemo + '%1' + Title + #13;
		downloadMessage := downloadMessage + '	' + Title + ' (' + Size + ')' + #13;
	end;

	i := GetArrayLength(products);
	SetArrayLength(products, i + 1);
	products[i].File := path;
	products[i].Title := Title;
	products[i].Parameters := Parameters;
	products[i].InstallClean := InstallClean;
	products[i].MustRebootAfter := MustRebootAfter;
end;


procedure InstallPackage(PackageName, FileName, Title, Size, URL: string);
var
	path: string;
begin
  missingDeps := true;
	installMemo := installMemo + '%1' + Title + #13;
	path := ExpandConstant('{src}{\}') + CustomMessage('DependenciesDir') + '\' + FileName;
	if not FileExists(path) then begin
		path := ExpandConstant('{tmp}{\}') + FileName;
		
		if not FileExists(path) then begin
			downloadMemo := downloadMemo + '%1' + Title + #13;
			downloadMessage := downloadMessage + Title + ' (' + Size + ')' + #13;
			
			isxdl_AddFile(URL, path);
		end;
	end;
	SetIniString('install', PackageName, path, ExpandConstant('{tmp}{\}dep.ini'));
end;

function SmartExec(prod : TProduct; var ResultCode : Integer) : boolean;
begin
	if (LowerCase(Copy(prod.File,Length(prod.File)-2,3)) = 'exe') then begin
		Result := Exec(prod.File, prod.Parameters, '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode);
	end else begin
		Result := ShellExec('', prod.File, prod.Parameters, '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode);
	end;
end;

function PendingReboot : boolean;
var	names: String;
begin
	if (RegQueryMultiStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager', 'PendingFileRenameOperations', names)) then begin
		Result := true;
	end else if ((RegQueryMultiStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager', 'SetupExecute', names)) and (names <> ''))  then begin
		Result := true;
	end else begin
		Result := false;
	end;
end;


function DotNetFrameworkInstalled(showError: boolean): boolean;
var
	version: string;
begin
  RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\.NETFramework\Policy\v2.0', '50727', version);
	Result := version <> '';  
	if not result and showError then SuppressibleMsgBox(CustomMessage('NoDotNetFrameworkFatal'), mbError, MB_OK, MB_OK);
end;

function LibreOfficeInstalled(showError: boolean): boolean;
var
	version: string;
begin
  RegQueryStringValue(HKLM, 'SOFTWARE\Wow6432Node\LibreOffice\UNO\InstallPath', '', version);
	Result := version <> '';  
	if not result and showError then SuppressibleMsgBox(CustomMessage('NoLibreOfficeFatal'), mbError, MB_OK, MB_OK);
end;

function CalibreInstalled(showError: boolean): boolean;
var
	version: string;
begin
  RegQueryStringValue(HKLM, 'SOFTWARE\Wow6432Node\calibre\Installer', 'InstallPath', version);
	Result := version <> '';  
	if not result and showError then SuppressibleMsgBox(CustomMessage('NoCalibreFatal'), mbError, MB_OK, MB_OK);
end;

function PDFXChangeViewerInstalled(showError: boolean): boolean;
var
	version: string;
begin
  RegQueryStringValue(HKLM, 'SOFTWARE\Tracker Software\PDFViewer', 'InstallPath', version);
	Result := version <> '';  
	if not result and showError then SuppressibleMsgBox(CustomMessage('NoPDFXChangeViewerFatal'), mbError, MB_OK, MB_OK);
end;

function PrinceXmlInstalled(showError: boolean): boolean;
var
	version: string;
begin
  RegQueryStringValue(HKLM, 'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Prince_is1', 'InstallLocation', version);
	Result := version <> ''; 
  
  if not Result then begin
    RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Prince_is1', 'InstallLocation', version);	
    Result := version <> '';  
  end;
  
  if not Result then begin
    RegQueryStringValue(HKLM, 'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{3AC28E9C-8F06-4E2C-ADDA-726E2230A03A}', 'InstallLocation', version);	
    Result := version <> '';    
  end;

  if not Result then begin
    RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{3AC28E9C-8F06-4E2C-ADDA-726E2230A03A}', 'InstallLocation', version);	
    Result := version <> '';
  end;

	if not result and showError then SuppressibleMsgBox(CustomMessage('NoPrinceXmlFatal'), mbError, MB_OK, MB_OK);
end;

function XelatexInstalled(showError: boolean): boolean;
var
	version: string;
begin
  RegQueryStringValue(HKLM, 'SOFTWARE\Wow6432Node\SIL\PathwayXeLaTeX', 'XeLaTexVer', version);
	Result := version <> ''; 
  
  {MsgBox(version, mbError, MB_OK);}
	if not result and showError then SuppressibleMsgBox(CustomMessage('NoXelatexFatal'), mbError, MB_OK, MB_OK);
end;

function JREinstalled(showError: boolean): boolean;
var
	version: string;
begin
  RegQueryStringValue(HKLM, 'SOFTWARE\Wow6432Node\JavaSoft\Java Runtime Environment', 'CurrentVersion', version);
	Result := version >= '1.5';  
	if not result and showError then SuppressibleMsgBox(CustomMessage('NoJREFatal'), mbError, MB_OK, MB_OK);
end;
                          

procedure checkJRE();
begin
	if not JREinstalled(false) then begin
		InstallPackage('jre6', 'jre6.exe', CustomMessage('jre6_title'), CustomMessage('jre6_size'), jre6_url);
	end;
end;

function InstallProducts: InstallResult;
var
	ResultCode, i, productCount, finishCount: Integer;
begin
	Result := InstallSuccessful;
	productCount := GetArrayLength(products);

	if productCount > 0 then begin
		DependencyPage := CreateOutputProgressPage(CustomMessage('depinstall_title'), CustomMessage('depinstall_description'));
		DependencyPage.Show;

		for i := 0 to productCount - 1 do begin
			if (products[i].InstallClean and (delayedReboot or PendingReboot())) then begin
				Result := InstallRebootRequired;
				break;
			end;

			DependencyPage.SetText(FmtMessage(CustomMessage('depinstall_status'), [products[i].Title]), '');
			DependencyPage.SetProgress(i, productCount);

			if SmartExec(products[i], ResultCode) then begin
				//setup executed; ResultCode contains the exit code
				//MsgBox(products[i].Title + ' install executed. Result Code: ' + IntToStr(ResultCode), mbInformation, MB_OK);
				if (products[i].MustRebootAfter) then begin
					//delay reboot after install if we installed the last dependency anyways
					if (i = productCount - 1) then begin
						delayedReboot := true;
					end else begin
						Result := InstallRebootRequired;
					end;
					break;
				end else if (ResultCode = 0) then begin
					finishCount := finishCount + 1;
				end else if (ResultCode = 3010) then begin
					//ResultCode 3010: A restart is required to complete the installation. This message indicates success.
					delayedReboot := true;
					finishCount := finishCount + 1;
				end else begin
					Result := InstallError;
					break;
				end;
			end else begin
				//MsgBox(products[i].Title + ' install failed. Result Code: ' + IntToStr(ResultCode), mbInformation, MB_OK);
				Result := InstallError;
				break;
			end;
		end;

		//only leave not installed products for error message
		for i := 0 to productCount - finishCount - 1 do begin
			products[i] := products[i+finishCount];
		end;
		SetArrayLength(products, productCount - finishCount);

		DependencyPage.Hide;
	end;
end;

function PrepareToInstall(var NeedsRestart: boolean): String;
var
	i: Integer;
	s: string;
begin
	delayedReboot := false;

	case InstallProducts() of
		InstallError: begin
			s := CustomMessage('depinstall_error');

			for i := 0 to GetArrayLength(products) - 1 do begin
				s := s + #13 + '	' + products[i].Title;
			end;

			Result := s;
			end;
		InstallRebootRequired: begin
			Result := products[0].Title;
			NeedsRestart := true;

			//write into the registry that the installer needs to be executed again after restart
			RegWriteStringValue(HKEY_CURRENT_USER, 'SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce', 'InstallBootstrap', ExpandConstant('{srcexe}'));
			end;
	end;
end;

function NeedRestart : boolean;
begin
	if (delayedReboot) then
		Result := true;
end;

function IsX86: boolean;
begin
	Result := (ProcessorArchitecture = paX86) or (ProcessorArchitecture = paUnknown);
end;

function IsX64: boolean;
begin
	Result := Is64BitInstallMode and (ProcessorArchitecture = paX64);
end;

function IsIA64: boolean;
begin
	Result := Is64BitInstallMode and (ProcessorArchitecture = paIA64);
end;

function GetString(x86, x64, ia64: String): String;
begin
	if IsX64() and (x64 <> '') then begin
		Result := x64;
	end else if IsIA64() and (ia64 <> '') then begin
		Result := ia64;
	end else begin
		Result := x86;
	end;
end;

function GetArchitectureString(): String;
begin
	if IsX64() then begin
		Result := '_x64';
	end else if IsIA64() then begin
		Result := '_ia64';
	end else begin
		Result := '';
	end;
end;


var
  Form: TSetupForm;
  Page,LicensePage: TWizardPage;
  UserPage: TInputQueryWizardPage;
  VersionPage: TInputOptionWizardPage;
  DependenPage: TInputOptionWizardPage;  
  BitmapImage, BitmapImage2, BitmapImage3,BackgroundBitmapImage: TBitmapImage;
  BitmapFileName,richtextstring,LicenseFileName: String;
  BackgroundBitmapText: TNewStaticText;
  ImproveCheckBox,AgreeCheckBox:TNewCheckBox;
  IsRegisteredUser: Boolean;
  RichEditViewer : TRichEditViewer;
  VersionValue: AnsiString;
  VersionFile: string; 
    
  procedure CheckBoxOnClick(Sender : TObject);



var
	installMemo, downloadMemo, downloadMessage: string;
	products: array of TProduct;
	delayedReboot: boolean;
  
var
 Msg : String;
 I   : Integer;
begin
   // Click Event, allowing inspection of the Values.
    WizardForm.NextButton.Enabled:=AgreeCheckBox.checked;
end;
procedure InitializeWizard;
begin
LicensePage := CreateCustomPage(wpWelcome,
  'License Information', '');
  RichEditViewer := TRichEditViewer.Create(LicensePage);
  RichEditViewer.Width := LicensePage.SurfaceWidth-10;
  RichEditViewer.Height := LicensePage.SurfaceHeight-50;
  RichEditViewer.Parent := LicensePage.Surface;
  RichEditViewer.ScrollBars := ssVertical;
  RichEditViewer.UseRichEdit := True;
  LicenseFileName:= ExpandConstant('{tmp}\License.rtf');
  ExtractTemporaryFile(ExtractFileName(LicenseFileName));
   VersionFile :=LicenseFileName;
   LoadStringFromFile(VersionFile, VersionValue);
  RichEditViewer.RTFText:= VersionValue;
  {RichEditViewer.ReadOnly := True;}
  AgreeCheckBox:= TNewCheckBox.Create(LicensePage);
  AgreeCheckBox.Caption:='Yes, I accept the terms and conditions';
  AgreeCheckBox.Checked:=False;
  AgreeCheckBox.Parent:=LicensePage.Surface;
  AgreeCheckBox.Top := RichEditViewer.Height+10;
  AgreeCheckBox.Width:=280;
  AgreeCheckBox.OnClick := @CheckBoxOnClick; 
  { Create the pages }
  Page := CreateCustomPage(LicensePage.ID, 'Improve', '');   
  BitmapFileName :=ExpandConstant('{tmp}\PathwayLogo.bmp');
  ExtractTemporaryFile(ExtractFileName(BitmapFileName));
  BitmapImage := TBitmapImage.Create(Page);
  BitmapImage.AutoSize := False;
  BitmapImage.Stretch := True;
  BitmapImage.Bitmap.LoadFromFile(BitmapFileName);
  BitmapImage.Parent := Page.Surface; 
  BitmapImage.Left :=1;
  BitmapImage.Height := 100;
  BitmapImage.Width := 100;
  {StaticText := TNewStaticText.Create(Page);
  StaticText.Caption := 'Welcome and thank you for choosing to install Pathway.\n Pathway will add additional printing and exporting capabilities';
  StaticText.AutoSize := True;
  StaticText.Parent := Page.Surface; }
  BackgroundBitmapText := TNewStaticText.Create(Page);
  BackgroundBitmapText.Left := BitmapImage.Left+120;
  BackgroundBitmapText.Width:=300;
  BackgroundBitmapText.WordWrap:=True;
  BackgroundBitmapText.Caption := 'Welcome and thank you for choosing to install Pathway. Pathway will add additional printing and exporting capabilities';
  BackgroundBitmapText.Font.Color := clBlack;
  BackgroundBitmapText.Font.Size:=14;
  BackgroundBitmapText.Parent := Page.Surface; 
  ImproveCheckBox:= TNewCheckBox.Create(Page);
  ImproveCheckBox.Caption:='Yes, I would like to help improve pathway';
  ImproveCheckBox.Checked:=True;
  ImproveCheckBox.Top := BackgroundBitmapText.Top+200;
  ImproveCheckBox.Left := BackgroundBitmapText.Left;
  ImproveCheckBox.Width:=280;
  ImproveCheckBox.Font.Color := clBlack;
  ImproveCheckBox.Font.Size:=8;
  ImproveCheckBox.Parent := Page.Surface;
  UserPage := CreateInputQueryPage(Page.ID,
    'Personal Information', 'Who are you?',
    'Please specify your name and the company for whom you work, then click Next.');
  UserPage.Add('Name:', False);
  UserPage.Add('Company:', False);
  UserPage.Add('Email:', False);
  VersionPage := CreateInputOptionPage(UserPage.ID,
    'Version Information', 'Which version of Pathway would you like to install?',
    'Please select any one Pathway Version Option, then click Next.',
    True, False);
  VersionPage.Add('Stable');
  VersionPage.Add('Latest');
                 
   DependenPage := CreateInputOptionPage(VersionPage.ID,
    'Dependency Information', 'Do you have all the dependencies installed in your computer?',
    'After analyzing what is available in your computer, Pathway bootstrap will download and install the following applications.',
    False, False);
    DependenPage.Add('Microsoft Dotnet 2.0');
    DependenPage.Add('Java runtime(Go Bible,Epub)');
    DependenPage.Add('LibreOffice');
    DependenPage.Add('Epub(e-book reader');
    DependenPage.Add('PDF reader');
    DependenPage.Add('PrinceXML(XHTML to PDF)');
    DependenPage.Add('XeLaTeX(typesetting)');
           
    DependenPage.Values[0] := True;
    
  { Set default values, using settings that were stored last time if possible }

  UserPage.Values[0] := GetPreviousData('Name', ExpandConstant('{sysuserinfoname}'));
  UserPage.Values[1] := GetPreviousData('Company', ExpandConstant('{sysuserinfoorg}'));

  case GetPreviousData('VersionMode', '') of
    'Stable': VersionPage.SelectedValueIndex := 0;
    'Latest': VersionPage.SelectedValueIndex := 1;
  else
    VersionPage.SelectedValueIndex := 1;
  end;                   
end;


procedure RegisterPreviousData(PreviousDataKey: Integer);
var
  VersionMode: String;
begin
  { Store the settings so we can restore them next time }
  SetPreviousData(PreviousDataKey, 'Name', UserPage.Values[0]);
  SetPreviousData(PreviousDataKey, 'Company', UserPage.Values[1]);
  SetPreviousData(PreviousDataKey, 'EmailId', UserPage.Values[2]);

  case VersionPage.SelectedValueIndex of
    0: VersionMode := 'Stable';
    1: VersionMode := 'Latest';
  end;
  SetPreviousData(PreviousDataKey, 'VersionMode', VersionMode);  
end;

procedure RemoveProducts();
begin
   installMemo:='';
   downloadMemo:='';
   downloadMessage:='';
   SetArrayLength(products, 0);
   isxdl_ClearFiles();
end;

procedure CallDownload;
begin

      RemoveProducts();   
      
      if DependenPage.Values[0] then begin            
           if (not netfxinstalled(NetFx20, '')) then
              AddProduct('dotnetfx20' + GetArchitectureString() + '.exe',
                '/passive /norestart /lang:ENU',
                CustomMessage('dotnetfx20_title'),
                CustomMessage('dotnetfx20_size'),
                GetString(dotnetfx20_url, dotnetfx20_url_x64, dotnetfx20_url_ia64),
                false, false);
      end;
      if VersionPage.Values[0]  then begin
      AddProduct('{#StableExeName}',
                '/norestart',
                CustomMessage('stable_title'),
                CustomMessage('stable_size'),
                stable_url,
                false, false);
      end;
      if VersionPage.Values[1]  then begin
      AddProduct('{#LatestExeName}',
                '/norestart',
                CustomMessage('latest_title'),
                CustomMessage('latest_size'),
                Latest_url,
                false, false);
      end;
      if DependenPage.Values[1] then begin
             checkJRE();
      end;
      if DependenPage.Values[2] then begin
             AddProduct('LibreOffice_4.3.2_Win_x86.msi',
                '/passive /norestart',
                CustomMessage('Libreoffice_title'),
                CustomMessage('Libreoffice_size'),
                Libreoffice_url,
                false, false);
      end;
      if DependenPage.Values[3] then begin
             AddProduct('calibre-2.7.0.msi',
                '/passive /norestart',
                CustomMessage('epub_title'),
                CustomMessage('epub_size'),
                epub_url,
                false, false);
      end;
      if DependenPage.Values[4] then begin
           AddProduct('PDFXVwer.exe',
                      '/passive /norestart',
                      CustomMessage('pdfViewer_title'),
                      CustomMessage('pdfViewer_size'),
                      pdfViewer_url,
                      false, false);                  
      end;
      if DependenPage.Values[5] then begin
          AddProduct('prince-9.0r5-setup.exe',
                      '/norestart',
                      CustomMessage('princeXml_title'),
                      CustomMessage('princeXml_size'),
                      princeXml_url,
                      false, false);   
      end;
      if DependenPage.Values[6] then begin
           AddProduct('SetupXeLaTeXTesting-1.10.0.3926.msi',
                '/passive /norestart',
                CustomMessage('xelatex_title'),
                CustomMessage('xelatex_size'),
                xelatex_url,
                false, false); 
      end;
	  
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  i: Integer;
  s: string;
var
  UsageMode: String;

begin

  { Validate certain pages before allowing the user to proceed }
  if CurPageID = UserPage.ID then begin
    if UserPage.Values[0] = '' then begin
      MsgBox('You must enter your name.', mbError, MB_OK);
      Result := False;
     end else begin
      Result := True;
     end;    
  end else if CurPageID = DependenPage.ID then begin
        CallDownload();

       if SuppressibleMsgBox(FmtMessage(CustomMessage('depdownload_msg'), [downloadMessage]), mbConfirmation, MB_YESNO, IDYES) = IDNO then
				Result := false
			else if isxdl_DownloadFiles(StrToInt(ExpandConstant('{wizardhwnd}'))) = 0 then
				Result := false;  
             
      Result := true;	
  end else
    Result := True;
end;
procedure CurPageChanged(CurPageID: Integer);
var
	i: Integer;
begin
  if CurPageID = LicensePage.ID then begin
  WizardForm.NextButton.Enabled:=AgreeCheckBox.checked;
  end;
  if CurPageID = DependenPage.ID then begin   

    if DotNetFrameworkInstalled(false) then begin
        DependenPage.CheckListBox.ItemEnabled[0]:=false;
        DependenPage.Values[0] := False;
    end;
    if JREinstalled(false) then begin
        DependenPage.CheckListBox.ItemEnabled[1]:=false;
    end;
    if LibreOfficeInstalled(false) then begin
        DependenPage.CheckListBox.ItemEnabled[2]:=false;
    end;
    if CalibreInstalled(false) then begin
        DependenPage.CheckListBox.ItemEnabled[3]:=false;
    end;
    if PDFXChangeViewerInstalled(false) then begin
        DependenPage.CheckListBox.ItemEnabled[4]:=false;
    end;
    if PrinceXmlInstalled(false) then begin
        DependenPage.CheckListBox.ItemEnabled[5]:=false;
    end;                                           
    if XelatexInstalled(false) then begin
        DependenPage.CheckListBox.ItemEnabled[6]:=false;
    end;                                       
  end;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin 
  if PageID = UserPage.ID then begin
      if ImproveCheckBox.Checked = False then begin
      Result:=True;
      end 
      end
      else begin
      Result:=False;
      end;
end;
function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo,
  MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
var
  S: String;
begin
  { Fill the 'Ready Memo' with the normal settings and the custom settings }
  S := '';
  S := S + 'Personal Information:' + NewLine;
  S := S + Space + UserPage.Values[0] + NewLine;
  if UserPage.Values[1] <> '' then
    S := S + Space + UserPage.Values[1] + NewLine;
  S := S + NewLine;
  
  S := S + 'Version Mode:' + NewLine + Space;
  case VersionPage.SelectedValueIndex of
    0: S := S + 'Stable mode';
    1: S := S + 'Latest mode';
  end;
  S := S + NewLine + NewLine;
  
  S := S + MemoDirInfo + NewLine;
  S := S + Space + ' (personal data files)' + NewLine;

  Result := S;
end;

function GetUser(Param: String): String;
begin
  { Return a user value }
  { Could also be split into separate GetUserName and GetUserCompany functions }
  if Param = 'Name' then
    Result := UserPage.Values[0]
  else if Param = 'Company' then
    Result := UserPage.Values[1];
end;


function IsStable: Boolean;
begin
     if(VersionPage.SelectedValueIndex=0) then 
     Result:= True
     else
     Result:=False;
end;

function GetNumber(var temp: String): Integer;
var
part: String;
pos1: Integer;
begin
if Length(temp) = 0 then
begin
Result := -1;
Exit;
end;
pos1 := Pos('.', temp);
if (pos1 = 0) then
begin
Result := StrToInt(temp);
temp := '';
end
else
begin
part := Copy(temp, 1, pos1 - 1);
temp := Copy(temp, pos1 + 1, Length(temp));
Result := StrToInt(part);
end;
end;
function CompareInner(var temp1, temp2: String): Integer;
var
num1, num2: Integer;
begin
num1 := GetNumber(temp1);
num2 := GetNumber(temp2);
if (num1 = -1) or (num2 = -1) then
begin
Result := 0;
Exit;
end;
if (num1 > num2) then
begin
Result := 1;
end
else if (num1 < num2) then
begin
Result := -1;
end
else
begin
Result := CompareInner(temp1, temp2);
end;
end;
function CompareVersion(str1, str2: String): Integer;
var
temp1, temp2: String;
begin
temp1 := str1;
temp2 := str2;
Result := CompareInner(temp1, temp2);
end;



	



