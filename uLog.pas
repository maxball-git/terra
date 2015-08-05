unit uLog;

interface

uses System.SysUtils, System.Types,System.Classes, VCL.Dialogs, ansistrings;

var
  CurModuleName : string = 'uLog';

type

  TLogProc = procedure (Detalization:integer;Str:string);
  PLogProc = ^TLogProc;

  TLog = class
  private
    fListOfLogProc:TStringList;
    fCurrentProc: PLogProc;
    fLastDetalization:integer;
    function GetLogProcByName(ProcName: string): PLogProc;
  public
    procedure RegisterLogProc(Name: string; Proc: PLogProc);
    property LogProcByName[ProcName: string]:PLogProc read GetLogProcByName;
    procedure UnregisterLogProc(Name :string);overload;
    procedure UnregisterLogProc(Proc: PLogProc);overload;
    constructor Create;virtual;
    destructor Destroy;override;
    property CurrentProc:PLogProc read fCurrentProc write fCurrentProc;
    procedure WriteAll(Detalization:integer;Str:string);
    procedure Write(Str:string);overload;
    procedure Write(Detalization:integer;Str:string);overload;
    function GetCurTime:string;
  end;

var
  Log:TLog = nil;

  LogFile: TFileStream;

const
  LD_Application=1;
  LD_DB = 2;
  LD_DBFIELD = 4;

implementation

uses uConsts;

procedure  DoLogToMessage(Detalization:integer;Str:string);
begin
  ShowMessage(Str);
end;

procedure  DoLogToFile(Detalization:integer;Str:string);
var buf:string;
    Temp:AnsiString;
    T2:PByteArray;
    t3 : array [0..255] of byte;
begin
  buf := #13+StringOfChar(' ',8-length(Str))+Detalization.ToString+#9+Str;
  Temp := ansistring(Buf);
  LogFile.write(Pointer(Temp)^,length(Temp)*SizeOf(AnsiChar));
end;

{ TLog }

constructor TLog.Create;
begin
  inherited;
  fListOfLogProc:=TStringList.Create;
end;

destructor TLog.Destroy;
begin
  fListOfLogProc.Clear;
  FreeAndNil(fListOfLogProc);
  inherited;
end;

function TLog.GetCurTime: string;
begin
  // use formatdatetime for custom format
  Result := DateTimeToStr(now);
end;

function TLog.GetLogProcByName(ProcName: string): PLogProc;
var
  i:NativeInt;
begin
  Result := nil;
  for i := 0 to fListOfLogProc.Count -1 do
    if UpperCase(fListOfLogProc[i])=UpperCase(ProcName) then
    begin
      Result := PLogProc(fListOfLogProc.Objects[i]);
      break;
    end;
end;

procedure TLog.RegisterLogProc(Name: string; proc: PLogProc);
var
  b:boolean;
begin
  b:=true;
  if not Assigned(Proc) then
  begin
    Write(0,NewOffer([cs_procedure,'"uLog->Log->RegisterLogProc"',csDot, cs_Received, cs_an, cs_invalid, cs_parameter, '"Proc"',csDot]));
    b:=b and false;
  end;
  if (fListOfLogProc.IndexOfObject(Tobject(proc))>=0) then
  begin
    Write(0,NewOffer([cs_procedure,'"uLog->Log->RegisterLogProc"',csDot, cs_Received, cs_an, cs_invalid, cs_parameter, '"Proc"',csDot, cs_value, cs_is, cs_already, cs_in, cs_the, cs_list, csDot]));
    b:=b and false;
  end;
  if (fListOfLogProc.IndexOf(Name)>=0) then
  begin
    Write(0,NewOffer([cs_procedure,'"uLog->Log->RegisterLogProc"',csDot, cs_Received, cs_an, cs_invalid, cs_parameter, '"Proc"',csDot, cs_value, '"'+Name+'"', cs_is, cs_already, cs_in, cs_the, cs_list, csDot]));
    b:=b and false;
  end;
  if b then
  begin
    fListOfLogProc.AddObject(Name,pointer(proc));
    if fListOfLogProc.Count = 1 then fCurrentProc:=proc;
  end;
end;

procedure TLog.UnregisterLogProc(Name: string);
begin

end;

procedure TLog.UnregisterLogProc(Proc: PLogProc);
begin

end;

procedure TLog.WriteAll(Detalization: integer; Str: string);
var
  i: Integer;
begin
  if fListOfLogProc.Count=0 then
  begin
    ShowMessage(NewOffer(['log proc not found.']));
    Exit;
  end;
  for i := 0 to fListOfLogProc.Count - 1 do
  begin
    TLogProc(fListOfLogProc.Objects[fListOfLogProc.Count-1])(Detalization,Str);
  end;
end;

procedure TLog.Write(Str: string);
begin
  Write(fLastDetalization,str);
end;

procedure TLog.Write(Detalization: integer; Str: string);
var proc : TLogProc;
begin
  if Assigned(fCurrentProc) then
  begin
    fLastDetalization := Detalization;
    proc := TLogProc(fCurrentProc);
    proc(Detalization,GetCurTime+#9+Str);
  end;
end;

var lf:string;
initialization
  lf := ChangeFileExt(Paramstr(0),'.log');

  if not FileExists(lf) then
    LogFile := TFileStream.Create(lf,fmCreate)
  else
    LogFile := TFileStream.Create(lf,fmOpenWrite);
  LogFile.Seek(0,soFromEnd);

  Log:=TLog.Create;
  Log.RegisterLogProc('LogToFile',@DoLogToFile);
  Log.RegisterLogProc('LogToMessage',@DoLogToMessage);
  Log.CurrentProc:=@DoLogToMessage;

finalization
  LogFile.Free;
end.
