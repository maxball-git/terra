unit uDBCustomObjects;

interface

uses uConsts, uDB,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, VCL.Dialogs,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, TypInfo, FireDAC.Stan.Def,
  FireDAC.Phys, FireDAC.Stan.Pool,FireDAC.Phys.MySQL, Vcl.Menus,
  FireDAC.Phys.MySQLDef, FireDAC.Phys.ODBC, Vcl.ActnList,
  FireDAC.Phys.ODBCDef, FireDAC.UI.Intf, FireDAC.VCLUI.Wait ,
  FireDAC.Comp.UI, Vcl.ComCtrls, Vcl.StdCtrls, VCL.Controls,
  uLog, Vcl.Imaging.pngimage;

type

  TDBUser = class (TDBTypicalObject)
  private
    fUsergrants: string;
    fContactid: string;
    fPassword: string;
    fLogin: string;
    fRole: TID;
  published
    property Login:string read fLogin write fLogin;
    property password:string read fPassword write fPassword;
    property contactid:string read fContactid write fContactid;
    property usergrants:string read fUsergrants write fUsergrants; //old field. use ACCESS now
    property role:Int64 read fRole write fRole;
  end;

  TWhereFunction = function (DBTable: TList; DBObject: TDBObject):boolean of object;

  TDBObjectTable = class(TList)
  private
    function SortByOrder(Item1, Item2: Pointer): Integer;
    function GetByID(ID: TId): TDBIDObject;
    function GetTableName(sql:string):string;
    function GetAllIdForInClause(propname:string):string;
  protected
    fQuery:TQuery;
    fClass:TDBObjectClass;
    fOnWhere:TWhereFunction;    // Custom WHERE proc
    fOrderBy:string;
    function Where(DBO: TDBObject):boolean;virtual; // base required WHERE
  public
    property Query:TQuery read fQuery;
    procedure LoadFromDB;
    procedure InitParams;virtual;
    constructor Create;virtual;
    destructor Destroy;override;
    property OrderBy:string read fOrderBy write fOrderBy; // := 'Name,Weight,DateCreate'  By default := 'weight';
    property ByID[ID:TId]:TDBIDObject read GetByID;
    Property AllIdForInClause[propname:string]:string read GetAllIdForInClause;
  end;

  TDBUsers = class(TDBObjectTable)
  public
    procedure InitParams;override;
  end;

  TDBDictionary = class(TDBObjectTable)
  private 
    fSQL : string;
  protected
    function Where(DBO: TDBObject):boolean;override;
  public 
    constructor Create(aSQL:string; aDBClass:TDBObjectClass);overload;
    procedure InitParams;override; 
  end;
  
  TDBAcces = class(TDBGrantedObject)
  private
    fName: string;
  published
    property Name:string read fName write fName;
  end;

  TDBAction = class(TDBTypicalObject)
  private
    fIMAGEINDEX:Integer;
    fCAPTION:string;
    fHINT:string;
    fCOMMAND:string;
  public
    procedure UpdateComponent(Action:TAction);
  published
    property IMAGEINDEX:Integer read fIMAGEINDEX write fIMAGEINDEX;
    property CAPTION:string read fCAPTION write fCAPTION;
    property HINT:string read fHINT write fHINT;
    property COMMAND:string read fCOMMAND write fCOMMAND;
  end;

  TDBMenuItem = class (TDBAction)
  private
    fItems: TList;
    fPARENT:TID;
  public
    property Items:TList read fItems write fItems;
    constructor Create(aQuery: TFDQuery; ParseNow: boolean = true);override;
    procedure UpdateComponent(MenuItem:TMenuItem);
  published
    property PARENT:TID read fPARENT write fPARENT;
  end;



  // Groups of contacts
  TDBContactGroup = class (TDBAccessSortedObject)
  private
    fName: string;
    fParent: TID;
    fGroupType: TID;
  public
    procedure UpdateComponent(Node: TTreeNode);
  published
    property PARENT:TID read fParent write fParent;
    property NAME:string read fName write fName;
    property GROUPTYPE:TID read fGroupType write fGroupType;

  end;

  TDBContactsGroups = class(TDBObjectTable)
  public
    procedure InitParams;override;
  end;

  // Contacts
  TDBContact = class (TDBAccessSortedObject)
  private
    fGroupID:TId;
    fGroupType: TId;
    fFullName:string;     // Полное название
    fShortName:string;    // Короткое назание
    fAbbreviation:string;  // Аббревиатура
    fPost:string;
    fEmail:string;
    fPhones:string;
    fFaxes:string;
    fName:string;         // Имя
    fSurname:string;     // Фамилия
    fPatronymic:string;
    function GetDisplayName: string;  // Отчество
  public
    procedure UpdateComponent(Item: TListItem);
    property DisplayName:string read GetDisplayName;
  published
    property GroupID:TId read fGroupID write fGroupID;
    property GroupType:TId read fGroupType write fGroupType;
    property FullName:string read fFullName write fFullName;             // Полное название
    property ShortName:string read fShortName write fShortName;          // Короткое назание
    property Abbreviation:string read fAbbreviation write fAbbreviation; // Аббревиатура
    property Post:string read fPost write fPost;
    property Email:string read fEmail write fEmail;
    property Phones:string read fPhones write fPhones;
    property Faxes:string read fFaxes write fFaxes;
    property Name:string read fName write fName;                         // Имя
    property Surname:string read fSurname write fSurname;             // Фамилия
    property Patronymic:string read fPatronymic write fPatronymic;       // Отчество
  end;

  TDBContactsList = class(TDBObjectTable)
  public
    procedure InitParams;override;
  end;

  TDBContactsListByGroup = class(TDBContactsList)
  private
    fGroupID:TID;
  public
    constructor Create(aGroupID:TID);virtual;
    procedure InitParams;override;
  end;

  TDBCity = class(TDBIDObject)
  private
    fGEOCODE: TID;
    fNAMELAT: string;
    fNAMECYR: string;
    fCOUNTRY: TID;
    fPOINT: string;
  published
    property NAMECYR:string read fNAMECYR write fNAMECYR;
    property NAMELAT:string read fNAMELAT write fNAMELAT;
    property COUNTRY:TID read fCOUNTRY write fCOUNTRY;
    property GEOCODE:TID read fGEOCODE write fGEOCODE;
    property POINT:string read fPOINT write fPOINT;
  end;

  TDBCountry = class(TDBIDObject)
  private
    fNAMELAT: string;
    fNAMECYR: string;
    fPOINT: string;
    fFlag:TPngImage;
    fFullCyr: string;
    fALPHA2: string;
    fALPHA3: string;
    fPartOfWorld: TId;
    fISO: integer;
    fContinent: Byte;
    fFullLat: string;
  published
    property NAMECYR:string read fNAMECYR write fNAMECYR;
    property NAMELAT:string read fNAMELAT write fNAMELAT;
    property FullCyr:string read fFullCyr write fFullCyr;
    property FullLat:string read fFullLat write fFullLat;
    property FLAG:TPngImage read fFlag write fFlag;
    property POINT:string read fPOINT write fPOINT;
    property PartOfWorld:TId read fPartOfWorld write fPartOfWorld;
    property ALPHA2:string read fALPHA2 write fALPHA2;
    property ALPHA3:string read fALPHA3 write fALPHA3;
    property ISO:integer read fISO write fISO;
    property Continent:Byte read fContinent write fContinent;
  end;

  TDBUpdates = class(TDBObjectTable)
  public
    procedure InitParams;override;
  end;

  TDBUpdateRec = class(TDBIDObject)
  private
    fFilename: string;
    fVersion: string;
    fStream:TMemoryStream;
    function GetFILEDATA: TMemoryStream;
    procedure SetFILEDATA(const Value: TMemoryStream);

  published
    property VERSION:string read fVersion write fVersion;
    property FILEDATA:TMemoryStream read GetFILEDATA write SetFILEDATA;
    property FILENAME:string read fFilename write fFilename;
  end;

  TDBAppointment = class(TDB_ID_NAME_Object)
  private
    fDescription: string;
    fWeight: string;
  public
    procedure UpdateComponent(Item: TListItem);virtual;
  published
    property Description:string read fDescription write fDescription;
    property Weight:string read fWeight write fWeight;
  end;

  TDBAppointments = class(TDBObjectTable)
  protected
    function Where(DBO: TDBObject):boolean;override;
  public
    procedure InitParams;override;
  end;


  TDBContactAppointments = class;

  TDBContactAppointment = class(TDBIDObject)
  private
    fAppointmentID: TID;
    fContactID: TID;
    fDescription: string;
    fCompanyID: TID;
    fContact:TDBContact;
    fOwnerList:TDBContactAppointments;
    fAppointmentName: string;
    function GetAppointmentName: string;
    function GetEmployerName: string;
    function GetAppointmentDictObject: TDBAppointment;
    function GetEmployerDictobject: TDBContact;
  public
    property AppointmentDictObject:TDBAppointment read GetAppointmentDictObject;
    property AppointmentName:string read GetAppointmentName;
    property AppointmentsList:TDBContactAppointments read fOwnerList;
    property EmployerName : string read GetEmployerName;
    property EmployerDictobject : TDBContact read GetEmployerDictobject;
  published
    property ContactID:TID read fContactID write fContactID;
    property AppointmentID: TID read fAppointmentID write fAppointmentID;
    property CompanyID: TID read fCompanyID write fCompanyID;
    property Description: string read fDescription write fDescription;
  end;

  TDBContactAppointments = class(TDBObjectTable)
  private
    fContact:TDBContact;
    fDictAppointments:TDBAppointments;
    fEmployers:TDBDictionary;
  protected
    function Where(DBO: TDBObject):boolean;override;
  public
    procedure InitParams;override;
    constructor Create(aContact:TDBContact);overload;virtual;
    property DictAppointments:TDBAppointments read fDictAppointments;
    property DictEmployers : TDBDictionary read fEmployers;
  end;

  function GetCurrentRole:TID;
var
  CurrentUser:TDBUser;

implementation

function GetCurrentRole:TID;
begin
  if Assigned(CurrentUser) then
    Result := CurrentUser.fRole
  else
    Result := DBR_NONE
end;

{ TDBMenuItem }
constructor TDBMenuItem.Create(aQuery: TFDQuery; ParseNow: boolean);
begin
  inherited Create(aQuery,ParseNow);
  fItems := TList.Create;
end;

procedure TDBMenuItem.UpdateComponent(MenuItem:TMenuItem);
begin
  MenuItem.Caption := fCAPTION;
  MenuItem.Hint := fHint;
  MenuItem.ImageIndex := fIMAGEINDEX;
  MenuItem.Tag:= integer(Self);
end;

{ TDBObjectTable }

constructor TDBObjectTable.Create;
begin
  inherited;
  fQuery:=NewQuery('');
  fOrderBy:='';
  fOnWhere := nil;
  InitParams;
  LoadFromDB;
end;

destructor TDBObjectTable.Destroy;
begin
  fQuery.Free;
  //DestroyDBList(self);
  inherited;
end;

function TDBObjectTable.GetAllIdForInClause(propname:string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to Count - 1 do
    Result := result + VarToStr(GetPropValue(TDBIDObject(items[i]),propname))+',';
  if Count > 0 then
    Result := Result.Remove(result.Length-1);
    
end;

function TDBObjectTable.GetByID(ID: TId): TDBIDObject;
var
  i,c: Integer;
begin
  Result := nil;
  c:= Count-1;
  for i := 0 to c do
    if TDBIDObject(Items[i]).ID = ID then
    begin
      Result:=  TDBIDObject(Items[i]);
    end;
end;

function TDBObjectTable.GetTableName(sql: string): string;
var s:string;
    p: Integer;
    fr:string;
    fl:integer;
begin
  fr := csS+cs_from+csS;
  fl := fr.Length;
  s:=sql;
  s:=StringReplace(s,fr,fr,[rfReplaceAll, rfIgnoreCase]);
  p := pos(fr,s);
  while p > 0 do
  begin
    s := s.Substring(p+fl-1);
    s:=s.Split([' ',')'])[0];
    p := pos(fr,s);
  end;
  Result := s;
end;

procedure TDBObjectTable.InitParams;
begin
  fClass:=TDBObject;
  fQuery.SQL.Text := '';
  fOrderBy:='';
  fOnWhere := nil; 
end;

function TDBObjectTable.Where(DBO: TDBObject):boolean;
begin
  Result := false;
  if DBO.FieldExists('ACCESS') then
  begin
    if Assigned(CurrentUser) then
    begin
      if (TDBGrantedObject(DBO).ACCESS And CurrentUser.Role) <> 0 then
        Result:=true;
    end
    else
      // CurrentUser not assigned
      // Login?
      if DBO.PropertyExists('login') and DBO.PropertyExists('password') then
      begin
        Result := true;
      end;
  end;
end;

procedure TDBObjectTable.LoadFromDB;
var 
  BM:TBookmark;
  DBO: TDBObject;
begin
  try
    fQuery.Open;
    Clear;
    BM := fQuery.GetBookmark;
    fQuery.DisableControls;
    fQuery.First;
    while not fQuery.Eof do
    begin
      DBO := fClass.Create(fQuery);
      if Where(DBO) then
      begin
        if assigned(fOnWhere) then 
        begin
          if fOnWhere(Self,DBO) then
            Add(DBO);
        end
        else
          Add(DBO);
      end;
      fQuery.Next;
    end;
    fQuery.GotoBookmark(BM);
    fQuery.EnableControls;
  except
    DBLog('Get object list error. '+fClass.ClassName);
  end;
  if Trim(fOrderBy).Length > 0 then 
    SortList(SortByOrder);  
end;

function TDBObjectTable.SortByOrder(Item1, Item2: Pointer): Integer;
var PropList:TStringList;
  function Recurse(PropName:string;Item1, Item2: TDBObject):integer;
  var i:integer;
  begin
    if GetPropValue(Item1,PropName) > GetPropValue(Item2,PropName)
    then 
      result := 1
    else
    if GetPropValue(Item1,PropName) < GetPropValue(Item2,PropName)
    then 
      result := -1
    else    
    begin
      i := PropList.IndexOf(PropName);
      if i < PropList.Count-1 then
        Result := Recurse(PropList[i+1],Item1, Item2)
      else
        Result := 0;
    end;    
  end;
begin
  PropList := TStringList.Create;
  PropList.Text:=StringReplace(fOrderBy,',',#13#10,[rfReplaceAll]);
  if PropList.Count>0 then
    Result := Recurse(PropList[0],TDBObject(Item1),TDBObject(Item2))
  else
    result := 0;
end;

{ TUsers }

procedure TDBUsers.InitParams;
begin
  fQuery.SQL.Text := Format(SQL_GET_USERS,[GetCurrentRole]);
  fClass:=TDBUser;
end;

{TDBDictionary}

procedure TDBDictionary.InitParams; 
begin
  fQuery.SQL.Text := fSQL;
end;

function TDBDictionary.Where(DBO: TDBObject): boolean;
begin
  Result := true;
end;

constructor TDBDictionary.Create(aSQL:string; aDBClass:TDBObjectClass);
begin
  fSQL := aSQL;
  fClass := aDBClass;
  Inherited Create;
end;

{ TDBContactGroups }

procedure TDBContactsGroups.InitParams;
begin
  fQuery.SQL.Text := Format(SQL_GET_CONTACTGROUPS,[GetCurrentRole]);
  fClass:=TDBContactGroup;
  OrderBy := '';
end;

{ TDBAction }

procedure TDBAction.UpdateComponent(Action:TAction);
begin
  try
    Action.Caption := fCAPTION;
    Action.Hint := fHint;
    Action.ImageIndex := fIMAGEINDEX;
    Action.Tag := integer(self);
  except

  end;
end;

{ TDBContactGroup }

procedure TDBContactGroup.UpdateComponent(Node: TTreeNode);
begin
  try
    Node.Text := fNAME;
    Node.ImageIndex := fGroupType;
    Node.Data := self;
  except

  end;
end;

{ TDBContact }

function TDBContact.GetDisplayName: string;
begin
  case fGroupType of
      0: begin
           Result := Trim(fFullName);
         end;
      1: begin
           Result := Trim(Trim(Trim(fSurname)+' '+trim(fName))+' '+trim(fPatronymic));
         end;
    end;
end;

procedure TDBContact.UpdateComponent(Item: TListItem);
begin
  inherited UpdateComponent(TComponent(Item));
  case fGroupType of
    0: begin
         Item.Caption := GetDisplayName;
         Item.SubItems.Clear;
         with Item.SubItems do
         begin
           Append(fPost);
           Append(fEmail);
           Append(fPhones);
           Append(fFaxes);
         end;
       end;
    1: begin
         Item.Caption := GetDisplayName;
         Item.SubItems.Clear;
         with Item.SubItems do
         begin
           Append(fPost);
           Append(fEmail);
           Append(fPhones);
           Append(fFaxes);
         end;
       end;
  end;
  Item.Data := self;

end;

{ TDBContactsList }

procedure TDBContactsList.InitParams;
begin
  fQuery.SQL.Text := Format(SQL_GET_CONTACTS,[GetCurrentRole]);
  fClass:=TDBContact;
  OrderBy := '';
end;



{ TDBUpdates }

procedure TDBUpdates.InitParams;
begin
  fQuery.SQL.Text := Format(SQL_GET_UPDATES,[getMyVersion]);
  fClass:=TDBUpdateRec;
  OrderBy := '';
end;

{ TDBUpdateRec }

function TDBUpdateRec.GetFILEDATA: TMemoryStream;
begin
  if Assigned(fStream) then
    Result := fStream
  else
  begin
    fStream:= TMemoryStream.Create;
    with NewQuery(Format(SQL_GET_UPDATES_BY_ID,[ID])) do
    begin
      if FieldByName(SQL_FILEDATA_FIELDNAME).IsBlob then
        TBlobField(FieldByName(SQL_FILEDATA_FIELDNAME)).SaveToStream(fStream);
    end;
    free;
  end;

end;

procedure TDBUpdateRec.SetFILEDATA(const Value: TMemoryStream);
begin

end;

{ TDictAppointment }

procedure TDBAppointments.InitParams;
begin
  fQuery.SQL.Text := SQL_GET_APPOINTMENTS;
  fClass:=TDBAppointment;
  OrderBy := 'weight';
end;

{ TDBContactAppointments }

constructor TDBContactAppointments.Create(aContact: TDBContact);
var sIDs:string;
begin
  fContact := aContact;
  inherited Create;
  fDictAppointments := TDBAppointments.Create;

  sIDs := AllIdForInClause['CompanyID'];
  if Trim(sIDs).Length > 0  then
    sIDs :=  cs_where + csS +'id in (' + sIDs + ')'
  else
    sIDs :=  cs_where + csS + '1=2';
  fEmployers := TDBDictionary.Create(
                 cs_select + csS + '*' + csS + cs_from + csS + cst_contacts
                    + csS +
                    sIDs
                ,TDBContact);

end;

procedure TDBContactAppointments.InitParams;
begin
  fQuery.SQL.Text := Format(SQL_GET_APPOINTMENTS_OF_CONTACT,[fContact.ID]);
  fClass:=TDBContactAppointment;
  OrderBy := '';
end;

function TDBContactAppointments.Where(DBO: TDBObject): boolean;
begin
  Result := true;
  TDBContactAppointment(DBO).fContact := fContact;
  TDBContactAppointment(DBO).fOwnerList := Self;
end;

function TDBAppointments.Where(DBO: TDBObject): boolean;
begin
  result := true;
end;

{ TDBAppointment }

procedure TDBAppointment.UpdateComponent(Item: TListItem);
begin
  Item.Caption := Name;

end;

{ TDBContactAppointment }

function TDBContactAppointment.GetAppointmentDictObject: TDBAppointment;
begin
  Result := TDBAppointment(fOwnerList.fDictAppointments.ByID[fAppointmentID]);
end;

function TDBContactAppointment.GetAppointmentName: string;
var dba: TDBAppointment;
begin
  Result := '';
  try
    dba := TDBAppointment(fOwnerList.fDictAppointments.ByID[fAppointmentID]);
    if assigned(dba) then
      Result := TDBAppointment(fOwnerList.fDictAppointments.ByID[fAppointmentID]).Name;
  except

  end;
end;

function TDBContactAppointment.GetEmployerDictobject: TDBContact;
begin
  Result := TDBContact(fOwnerList.fEmployers.ByID[fCompanyID]);
end;

function TDBContactAppointment.GetEmployerName: string;
begin
  try
    Result := GetEmployerDictobject.DisplayName;
  except
    Result := '';
  end;
end;

{ TDBContactsListByGroup }

constructor TDBContactsListByGroup.Create(aGroupID: TID);
begin
  fGroupID := aGroupID;
  inherited Create;
end;

procedure TDBContactsListByGroup.InitParams;
begin
  fQuery.SQL.Text := Format(SQL_GET_CONTACTS,[GetCurrentRole])+' AND GROUPID = '+IntToStr(fGroupID);
  fClass:=TDBContact;
  OrderBy := 'FullName';
end;

initialization


finalization


end.

