unit cm;
interface
uses Windows, ComObj, ShlObj, ActiveX;

type
  TContextMenu = class(TComObject, IContextMenu, IShellExtInit)
  private
    FFileName: array[0..MAX_PATH] of char;
    FMenuIdx: UINT;

  protected

    // metody interfejsu IContextMenu
    function QueryContextMenu(Menu: HMENU; indexMenu, idCmdFirst, idCmdLast,
      uFlags: UINT): HResult; stdcall;
    function InvokeCommand(var lpici: TCMInvokeCommandInfo): HResult; stdcall;
    function GetCommandString(idCmd, uType: UINT; pwReserved: PUINT;
      pszName: LPSTR; cchMax: UINT): HResult; stdcall;

    // metody interfejsu IShellExtInit
    function Initialize(pidlFolder: PItemIDList; lpdobj: IDataObject;
      hKeyProgID: HKEY): HResult; reintroduce; stdcall;
  end;

  TContextMenuFactory = class(TComObjectFactory)
  protected
    function GetProgID: string; override;
    procedure ApproveShellExtension(Register: Boolean; const ClsID: string);
      virtual;
  public
    procedure UpdateRegistry(Register: Boolean); override;
  end;

//*******************************************************************


implementation

uses ComServ, SysUtils, ShellAPI, Registry, Math;

//***************************************************

procedure ExecuteXorApp(const FileName: string; ParentWnd: HWND);
const
  SXorApp = '%sxorenc.exe';
  SCmdLine = '"%s" %s';
  SErrorStr = 'Error while executing xor encoder:'#13#10#13#10;
var
  PI: TProcessInformation;
  SI: TStartupInfo;
  ExeName, ExeCmdLine: string;
  Buffer: array[0..MAX_PATH] of char;
begin
//Get DLL directory name, assumming that xorenc is in the same directory
GetModuleFileName(HInstance, Buffer, SizeOf(Buffer));
  ExeName := Format(SXorApp, [ExtractFilePath(Buffer)]);
  ExeCmdLine := Format(SCmdLine, [ExeName, FileName]);
  FillChar(SI, SizeOf(SI), 0);
  SI.cb := SizeOf(SI);

  if not CreateProcess(PChar(ExeName), PChar(ExeCmdLine), nil, nil, False,
    0, nil, nil, SI, PI) then
     MessageBox(ParentWnd, PChar(SErrorStr + SysErrorMessage(GetLastError)),
      'Error', MB_OK or MB_ICONERROR);
end;

//***************************************************

function TContextMenu.QueryContextMenu(Menu: HMENU; indexMenu, idCmdFirst,
  idCmdLast, uFlags: UINT): HResult;
begin
  FMenuIdx := indexMenu;
  // Add new option to the context menu
  InsertMenu (Menu, FMenuIdx, MF_STRING or MF_BYPOSITION, idCmdFirst,
    'Encode Using XOR');
  // Return Index of First Free Position
  Result := FMenuIdx + 1;
end;

//***************************************************

function TContextMenu.InvokeCommand(var lpici: TCMInvokeCommandInfo): HResult;
begin
  Result := S_OK;
  try
    // Assure that command derives from server
    if HiWord(Integer(lpici.lpVerb)) <> 0 then
    begin
      Result := E_FAIL;
      Exit;
    end;
    // Execute command defined by lpici.lpVerb.
    if LoWord(lpici.lpVerb) = FMenuIdx then
      ExecuteXorApp(FFileName, lpici.hwnd)
    else
      Result := E_INVALIDARG;
  except
    MessageBox(lpici.hwnd, 'Error while attempting to open data file',
                           'Error',
                           MB_OK or MB_ICONERROR);
    Result := E_FAIL;
  end;
end;

//***************************************************

function TContextMenu.GetCommandString(idCmd, uType: UINT; pwReserved: PUINT;
  pszName: LPSTR; cchMax: UINT): HRESULT;
const
  SCmdStrA: String = 'Encode file using XOR Methode';
  SCmdStrW: WideString = 'Encode file using XOR Methode';
begin
  Result := S_OK;
  try
   if (idCmd = FMenuIdx) and ((uType and GCS_HELPTEXT) <> 0) then
    begin
     if Win32MajorVersion >= 5 then
        Move(SCmdStrW[1], pszName^,
          Min(cchMax, Length(SCmdStrW) + 1) * SizeOf(WideChar))
      else
        StrLCopy(pszName, PChar(SCmdStrA), Min(cchMax, Length(SCmdStrA) + 1));
    end
    else
      Result := E_INVALIDARG;
  except
    Result := E_UNEXPECTED;
  end;
end;

//***************************************************

function TContextMenu.Initialize(pidlFolder: PItemIDList; lpdobj: IDataObject;
  hKeyProgID: HKEY): HResult;
var
  Medium: TStgMedium;
  FE: TFormatEtc;
begin
  try
    // Error if lpdobj = nil.
    if lpdobj = nil then
    begin
      Result := E_FAIL;
      Exit;
    end;
    with FE do
    begin
      cfFormat := CF_HDROP;
      ptd := nil;
      dwAspect := DVASPECT_CONTENT;
      lindex := -1;
      tymed := TYMED_HGLOBAL;
    end;



    Result := lpdobj.GetData(FE, Medium);
    if Failed(Result) then Exit;
    try
      //Assure that only one file is selected

      if DragQueryFile(Medium.hGlobal, $FFFFFFFF, nil, 0) = 1 then
      begin
        DragQueryFile(Medium.hGlobal, 0, FFileName, SizeOf(FFileName));
        Result := NOERROR;
      end
      else
        Result := E_FAIL;
    finally
      ReleaseStgMedium(medium);
    end;
  except
    Result := E_UNEXPECTED;
  end;
end;

//***************************************************

function TContextMenuFactory.GetProgID: string;
begin
  // ProgID is not required for the extension server
  Result := '';
end;

//***************************************************

procedure TContextMenuFactory.UpdateRegistry(Register: Boolean);
var
  ClsID: string;
begin
  ClsID := GUIDToString(ClassID);
  inherited UpdateRegistry(Register);
  ApproveShellExtension(Register, ClsID);
  if Register then
  begin
   //  extension .xor has to be registered

   CreateRegKey('.xor', '', 'XorEncodedFile');
   CreateRegKey('txtfile\shellex\ContextMenuHandlers\' +
      ClassName, '', ClsID);
   CreateRegKey('XorEncodedFile\shellex\ContextMenuHandlers\' +
      ClassName, '', ClsID);
  end;

end;

//***************************************************

procedure TContextMenuFactory.ApproveShellExtension(Register: Boolean;
  const ClsID: string);


const
  SApproveKey = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved';
begin
  with TRegistry.Create do
    try
      RootKey := HKEY_LOCAL_MACHINE;
      if not OpenKey(SApproveKey, True) then Exit;
      if Register then WriteString(ClsID, Description)
      else DeleteValue(ClsID);
    finally
      Free;
    end;
end;

//***************************************************

const
  CLSID_CopyHook: TGUID = '{7C5E74A0-D5E0-11D0-A9BF-E886A83B9BE5}';

//***************************************************

initialization
  TContextMenuFactory.Create(ComServer, TContextMenu, CLSID_CopyHook,
    'DDG_ContextMenu', 'DDG Context Menu Shell Extension Example',
    ciMultiInstance, tmApartment);
end.

