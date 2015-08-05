unit uDB;

interface

uses uConsts,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, VCL.Dialogs,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, TypInfo, FireDAC.Stan.Def,
  FireDAC.Phys, FireDAC.Stan.Pool,FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef, FireDAC.Phys.ODBC,
  FireDAC.Phys.ODBCDef, FireDAC.UI.Intf, FireDAC.VCLUI.Wait ,
  FireDAC.Comp.UI, Controls, ComCtrls,

  uLog;

type // Base Type for Recoding to another database system
  TQuery = TFDQuery;
  TConnection = TFDConnection;
  TId = int64;
type
  TDbObjectMode = (dbomDBComponent, dbomSQL);

  TDBOperation = (doSelect, doInsert, doUpdate);
{$M+}
  // base object for read record from TQuery. Parsing from fields and write to fields.
  // ! don`t create a published property if it not a field of DB !
  TDBObject = class
  private
    fQuery:TQuery;
    //fFieldList:TStringList;
    //fPropertyList:TStringList;
    fTableName:string;
    fLastUpdatedComponent:TComponent;
    function GetTableName:string;
  public
    property LastUpdatedComponent:TComponent read fLastUpdatedComponent write fLastUpdatedComponent;
    constructor Create(aQuery: TQuery; ParseNow: boolean = true);virtual;
    destructor Destroy;override;
    procedure Parse;
    procedure ParseField(FieldName: string);
    function FieldExists(FieldName: string):boolean;
    function PropertyExists(PropName : string):boolean;
    procedure Write(FieldNames: array of string);
    procedure WriteField(FieldName: string);
    function GetPropertyList:string;
    function GetPropertyInfo:string;
    procedure UpdateComponent(Component:TComponent);virtual;
    property TableName:string read fTableName write fTableName;
  end;
{$M-}
  TDBObjectClass=class of TDBObject;

  TDB_ID_NAME_Object = class(TDBObject)  // for simple Dictionaries
  private
    fName: string;
    fID: TId;
  published
    property ID:TId read fID write fID;
    property Name:string read fName write fName;
  end;

  TDBGrantedObject = class(TDBObject)
  private
    fACCESS:TId;
  published
    property ACCESS:TId read fACCESS write fACCESS;
  end;

  TDBIDObject = class(TDBGrantedObject)
  private
    fID:TId;
    fLastUpdatedComponent:TComponent;
  public
    procedure WriteField(FieldName: string);virtual;
    property LastUpdatedComponent:TComponent read fLastUpdatedComponent write fLastUpdatedComponent;
    constructor Create(aQuery: TQuery; aID: TID; ParseNow: boolean = true; AddIfNotExists: boolean = true);overload;
  published
    property ID:TId read fID write fID;
  end;

  TDBTypicalObject = class(TDBIDObject)
  private
    fCREATOR:integer;
    fDATECREATE:TDateTime;
    fDELETED:boolean;
    fDATEDEL:TDateTime;
  published
    property CREATOR:integer read fCREATOR write fCREATOR;
    property DATECREATE:TDateTime read fDATECREATE write fDATECREATE;
    property DELETED:boolean read fDELETED write fDELETED;
    property DATEDEL:TDateTime read fDATEDEL write fDATEDEL;
  end;

  TDBAccessSortedObject = class(TDBTypicalObject)
  private
    fWeight: integer;
  published
    property WEIGHT:integer read fWeight write fWeight;
  end;

  procedure DBLog(str:string; detail:integer = LD_DB);
  procedure RecordsToStringList(aQuery: TQuery; Fields:array of variant; var SL: TStringList;
      FieldDelimiter: string = '|');

  function DBGet_ObjectList(ObjType:TDBObjectClass;aQuery:TQuery):TList;

  function CreateConnection:TConnection;
  function NewQuery(SQL:string):TQuery;
  procedure DestroyDBList(List:TList);
  function FindItemByID(aID:TID; aControl:TControl):TComponent;

var
  DefaultDBObjectMode:TDbObjectMode = dbomDBComponent;
  Connection :TConnection;

implementation

procedure DBWriteLog(Detalization:integer;Str:string);
begin
//  ShowMessage('uConsts.TraceWriteLog'+#13+'Detail Level='+inttoStr(Detalization)+#13+Str);
//  Procedure write log messages to DB
//  ...
end;

procedure DBLog(str:string; detail:integer = LD_DB); // using this procedure for current unit/
begin
  // write to system log
  uLog.Log.Write(detail,str);
end;

function DBGet_ObjectList(ObjType:TDBObjectClass;aQuery:TQuery):TList;
var
  BM:TBookmark;
begin
  Result:=TList.Create;
  try
    BM := aQuery.GetBookmark;
    aQuery.DisableControls;
    aQuery.First;
    while not aQuery.Eof do
    begin
      Result.Add(ObjType.Create(aQuery));
      aQuery.Next;
    end;
    aQuery.GotoBookmark(BM);
    aQuery.EnableControls;
  except
    DBLog('Get object list error. '+ObjType.ClassName);
  end;
end;

function FindItemByID(aID:TID; aControl:TControl):TComponent;
var
  i: Integer;
begin
  Result := nil;
  if aControl is TListView then
  begin
    for i := 0 to TListView(aControl).Items.Count - 1 do
    begin
      if TDBIDObject(TListView(aControl).Items[i].Data).fID = aID then
      begin
        Result := TComponent(TListView(aControl).Items[i]);
        break;
      end;
    end;
  end
  else
  ;
end;

{ TDBObject }

constructor TDBObject.Create(aQuery: TQuery; ParseNow: boolean);
begin
  Inherited Create;
  fQuery := aQuery;
  if assigned(fQuery) then
  begin
    fTableName := GetTableName;
    try
      try
        if ParseNow then Parse;
      finally

      end;
    except
      DBLog(NewOffer([Self.ClassName,cs_Object,cs_Parse,cs_Exception]));
    end;
  end;
end;

destructor TDBObject.Destroy;
begin
  //fFieldList.Free;
  //fPropertyList.Free;
  inherited Destroy;
end;

function TDBObject.FieldExists(FieldName: string): boolean;
var
  i: Integer;
  fc: Integer;
begin
  Result := false;
  fc := fQuery.FieldCount-1;
  for i := 0  to fc do
    if trim(AnsiUpperCase(Fieldname)) =
       trim(AnsiUpperCase(fQuery.fields[i].FieldName))
    then
    begin
      Result := true;
      break;
    end;
end;

procedure TDBObject.ParseField(FieldName: string);
var Value:variant;
begin
  if FieldExists(FieldName) then
    try
      Value := fQuery.FieldByName(FieldName).Value;
      if Value <> Null then
        SetPropValue(Self,FieldName,value)
      else
        SetPropValue(Self,FieldName,0);
    except
      DBLog(NewOffer([Self.ClassName,csDot,cs_property, '"'+FieldName+'"',cs_not,cs_found]));
    end
  else
    DBLog(NewOffer([Self.ClassName,csDot,cs_field,'"'+FieldName+'"',cs_not,cs_found]));
end;

function TDBObject.PropertyExists(PropName: string): boolean;
var pl:string;
begin
  pl := #13#10+UpperCase(GetPropertyList)+#13#10;
  Result:=Pos(#13#10+UpperCase(PropName)+#13#10,pl) > 0
end;

procedure TDBObject.UpdateComponent(Component: TComponent);
begin
  fLastUpdatedComponent :=  Component;
end;

procedure RecordsToStringList(aQuery: TQuery; Fields:array of variant; var SL: TStringList;
  FieldDelimiter: string = '|');
var
  i,vt: Integer;
  s:string;
begin
  aQuery.First;
  while Not aQuery.Eof do
  begin
    for i := Low(Fields) to High(Fields) do
    begin
      vt := VarType(Fields[i]);
      case vt of
        varInteger,
        varSmallint,
        varSingle,
        varCurrency,
        varShortInt,
        varByte,
        varWord,
        varLongWord,
        varInt64,
        varUInt64
          :begin
            s := aQuery.Fields[i].AsString;
           end;
        varString,
        varOleStr,
        varStrArg,
        varUStrArg,
        varUString
         :begin
            s:=aQuery.fields[0].name;
            s := aQuery.FieldByName(Fields[i]).AsString;
          end;
      end;
     s:=s + FieldDelimiter
    end;
    if FieldDelimiter<>'' then
    begin
      if copy(s,length(s)-length(FieldDelimiter)+1,length(FieldDelimiter))=FieldDelimiter then
        Delete(s,length(s)-length(FieldDelimiter)+1,length(FieldDelimiter));
    end;
    SL.Append(s);
    aQuery.Next;
  end;

end;

function TDBObject.GetPropertyInfo: string;
Var
  numProps, I : Integer;
  props: PPropList;
  PropInfo: PPropInfo;
  s:string;
begin
  Try
    numProps := GetPropList(self, props);
    Try
      For I := 0 To numProps - 1 Do
      Begin
        try
          PropInfo := props^[I];
          try
            s:=s + string(PropInfo^.Name) +': '+string(PropInfo^.PropType^.Name) + #13#10;
          except end;
        Finally

        End; { Finally }
      End;
      FreeMem( props );
    Except
    End;
  Finally
  End;
  Result := s;
end;

function TDBObject.GetPropertyList:string;
Var
  numProps, I : Integer;
  props: PPropList;
  PropInfo: PPropInfo;
  s:string;
begin
  Try
    numProps := GetPropList(self, props);
    Try
      For I := 0 To numProps - 1 Do
      Begin
        try
          PropInfo := props^[I];
          try
            s:=s + string(PropInfo^.Name) + #13#10;
          except end;
        Finally

        End; { Finally }
      End;
      FreeMem( props );
    Except
    End;
  Finally
  End;
  Result := s;
end;


function TDBObject.GetTableName: string;
var s:string;
    p: Integer;
    fr:string;
    fl:integer;
begin
  fr := csS+cs_from+csS;
  fl := fr.Length;
  s:=fQuery.SQL.Text;
  s:=StringReplace(s,fr,fr,[rfReplaceAll, rfIgnoreCase]);
  p := pos(fr,s);
  while p > 0 do
  begin
    s := s.Substring(p+fl-1);
    s:=s.Split([' ',')'])[0];
    p := pos(fr,s);
  end;
end;

procedure TDBObject.WriteField(FieldName: string);
var F:TField;
    em:boolean;
begin
  try
    f:=fQuery.FieldList.Find(FieldName);
    if assigned(f) then
    if f.Value <> GetPropValue(Self,FieldName) then
    begin
      em := fQuery.State in dsEditModes;
      if em then
        f.Value := GetPropValue(Self,FieldName)
      else
      begin
        fQuery.Edit;
        f.Value := GetPropValue(Self,FieldName);
        fQuery.Post;
      end;
    end;
  except

  end;

end;

procedure TDBObject.Write(fieldnames: array of string);
var
  i: Integer;
  Props:TStringList;
  em:boolean;
begin
  em := false;
  if fQuery.Locate('ID',GetPropValue(Self,'ID'),[]) then
  begin
    if not (fQuery.State in dsEditModes) then
    begin
      fQuery.Edit;
      em:=true;
    end;
  end
  else
  begin
    if not (fQuery.State in dsEditModes) then
    begin
      fQuery.Append;
      em:=true;
    end
  end;
  try
    if length(FieldNames)=0 then
    begin
      Props := TStringList.Create;
      Props.Text := GetPropertyList;
      for i := 0 to Props.Count - 1 do
        WriteField(Props[i]);
      Props.Free;
    end
    else
      for i := low(FieldNames) to high(FieldNames) do
        WriteField(FieldNames[i]);
    if em then
    begin
      fQuery.Post;
    end;
  except
    if (fQuery.State in dsEditModes) and em then fQuery.Cancel;
  end;
end;

procedure TDBObject.Parse;
var i:integer;
    Props:TStringList;
begin
  Props := TStringList.Create;
  Props.Text :=  GetPropertyList;
  For I := 0 To Props.Count - 1 Do
  Begin
    try
      ParseField(Props[i]);
    except
      DBLog(NewOffer([Self.ClassName, csDot,
      '"'+Props[i]+'"', cs_Field, cs_Parse, cs_Exception]), LD_DBFIELD);
    end;
  End;
  Props.Free;
end;

function CreateConnection:TConnection;
begin  {
  Result := TConnection.Create(Nil);
  Result.DriverName:='ODBC';
  Result.Params.DriverID := 'ODBC';
  Result.Params.Database := 'TERRA';
  Result.Params.UserName := 'u0025_terra';
  Result.Params.Password := Char(Ord('T'))+
  copy('error',1,3)+Char(Ord('a'))+inttostr(1)+inttostr(2)+'3'+Char(Ord('#'))+Char(Ord('!'));
  Result.Params.Strings[Result.Params.IndexOfName('Database')]:= 'DataSource=TERRA';
  Result.Connected := True;
   }
  Result := TConnection.Create(Nil);
  Result.DriverName:='MySQL';
  Result.Params.Add('Server=u0025981.plsk.regruhosting.ru');
  Result.Params.Database := 'u0025981_newprotect';
  Result.Params.UserName := 'u0025_terra';
  Result.Params.Password := Char(Ord('T'))+
  copy('error',1,3)+Char(Ord('a'))+inttostr(1)+inttostr(2)+'3'+Char(Ord('#'))+Char(Ord('!'));
  Result.Params.Add('CharacterSet=utf8');
  Result.Connected := True;
  {Result.ExecSQL('SET character_set_client = latin1;');
  Result.ExecSQL('SET collation_connection = utf8_unicode_ci;');
  Result.ExecSQL('SET character_set_server = latin1;');
  Result.ExecSQL('SET collation_server = utf8_unicode_ci;'); }
end;

function NewQuery(SQL:string):TQuery;
begin
  Result:=TQuery.Create(nil);
  Result.Connection:=Connection;
  if SQL<>'' then
  begin
    Result.SQL.Text := SQL;
    Result.Open;
  end;
end;

procedure DestroyDBList(List:TList);
begin
  while List.Count>0 do
  begin
    TDBObject(List[List.Count-1]).Free;
    List.Delete(List.Count-1);
  end;
  List.Free;
end;

{ TDBIDObject }

constructor TDBIDObject.Create(aQuery: TQuery; aID: TId;
    ParseNow: boolean = true; AddIfNotExists: boolean = true);
var B:TBookmark;
begin
  Inherited Create(aQuery,false);
  if assigned(fQuery) then
  begin
    try
      try
        B:=fQuery.GetBookmark;
        try
          if aID > 0 then
          begin
            if fQuery.Locate('ID',aID,[loCaseInsensitive]) then
            begin
              if ParseNow then Parse;
            end
            else
            begin

            end;
          end
          else
          begin
            if AddIfNotExists then
            begin
              fQuery.Append;
              fQuery.Post;
//            B:=fQuery.GetBookmark;
              if ParseNow then Parse;
            end;
          end;
        except

        end;
      finally
        fQuery.GotoBookmark(B);
      end;
    except
      DBLog(NewOffer([Self.ClassName,cs_Object,cs_Parse,cs_Exception]));
    end;
  end;
end;


procedure TDBIDObject.WriteField(FieldName: string);
begin
  if fQuery.Locate('ID',fID,[]) then
    inherited;
end;

{ TDBAccessSortedObject }

initialization
  uLog.Log.RegisterLogProc('DBWriteLog', @DBWriteLog);
  Connection := CreateConnection;

finalization
  Connection.Free;
end.
