unit uConsts;

interface


uses
  System.SysUtils,Forms, System.Types, System.UITypes, System.Classes,
  System.Variants, WinApi.Messages, WinApi.ShellApi, WinApi.Windows ,IdHashMessageDigest, idHash,
  uLog;

type
  TCharSet = TSysCharSet;

  TLogProc = procedure (Detalization:integer;Str:string);

  TViewMode = (vmView, vmEdit);

const
  csk_YOULATER = 'YOULATER';
  // const strings
  csS = ' ';
  csDot = '.';
  cs_object    = 'object';
  cs_field     = 'field';
  cs_parse     = 'parse';
  cs_exception = 'exception';
  cs_error     = 'error';
  cs_not       = 'not';
  cs_found     = 'found';
  cs_is        = 'is';
  cs_read      = 'read';
  cs_only      = 'only';
  cs_mode      = 'mode';
  cs_in        = 'in';
  cs_SQL       = 'SQL';
  cs_edit      = 'edit';
  cs_procedure = 'procedure';
  cs_existing  = 'existing';
  cs_received  = 'received';
  cs_an        = 'an';
  cs_invalid   = 'invalid';
  cs_parameter = 'parameter';
  cs_this      = 'this';
  cs_value     = 'value';
  cs_already   = 'already';
  cs_the       = 'the';
  cs_list      = 'list';
  cs_start     = 'start';
  cs_action    = 'action';
  cs_from      = 'from';
  cs_application='application';
  cs_activate  = 'activate';
  cs_deactivate= 'deactivate';
  cs_minimize  = 'minimize';
  cs_restore   = 'restore';
  cs_settings  = 'settings';
  cs_change    = 'change';
  cs_flag      = 'flag';
  cs_section   = 'section';
  cs_help      = 'help';
  cs_hint      = 'hint';
  cs_message   = 'message';
  cs_property  = 'property';
  cs_select    = 'select';
  cs_where     = 'where';
  cs_and       = 'and';
  cs_as        = 'as';
  cs_order     = 'order';
  cs_by        = 'by';
  cs_order_by  = cs_order+csS+cs_by;
  cs_login     = 'login';
  cs_password  = 'password';
  cs_name      = 'name';
  cs_update    = 'update';
  cs_exist     = 'exist';
  cs_command   = 'command';
  cs_do        = 'do';
  cs_replace   = 'replace';
  cs_old       = 'old';
  cs_file      = 'file';
  cs_successfully = 'successfully';
  cs_execute   = 'execute';
  cs_exit      = 'exit';
  cs_download  = 'download';
  cs_on        = 'on';


  cs_ObjectParseException = cs_object+csS+cs_parse+csS+cs_exception;
  cs_FieldParseException = cs_field+csS+cs_parse+csS+cs_exception;


  function MD5(S: String): String;
  function NewOffer(arr:array of string):string;  // create offer from words
  function FormatOffer(offer:string):string;      // format words and punctuation

  function AnsiProperCase(const S: string; const WordDelims: TCharSet = [' ',',']): string;
  function AnsiOfferCase(const S: string; OfferDelims: TCharSet = ['.','!','?']): string;
  function DeleteDoubleSpaces(s:string):string;

  function GetMyVersion:string;
const //DB Consts

  DB_MenuTable = 't_menus';
  DB_MenuTableFields:array [0..6] of string = ('ID','CATEGORY','PARENT','IMAGEINDEX','CAPTION','HINT','COMMAND');
  DB_MenuCategoryField = 'CATEGORY';



const
// interface grants:
// ACCESS field in each record contains the sum of the roles, which it is available
  DBG_ALL           = $FFFFFFFFFFFFFFFF; // DBG_ALL = -1 and by default field ACCESS = -1
  DBG_NOBODY        = $0000000000000000;
  DBG_ADMINONLY     = $8000000000000000;
  DBG_EXCEPTVIEWONLY= $FFFFFFFFFFFFFFFE;
// Roles:
// It only specific bits is ON
  DBR_ADMIN         = $FFFFFFFFFFFFFFFF;  // for ADMIN all bits is ON

  DBR_NONE          = $0000000000000000;

  DBR_VIEWONLY      = $0000000000000001;
  DBR_MANAGER       = $0000000000000002;
  DBR_SENIORMANAGER = $0000000000000004;
  DBR_ACCOUNTANT    = $0000000000000008;
  DBR_DEPUTIDIRECTOR= $0000000000000010;
  DBR_DIRECTOR      = $0000000000000020;
  DBR_PRESIDENT     = $0000000000000040;

const
  WordDelims : TSysCharSet = [' ','-',',',':',';','+','*','~','`','@','#','$','%',
                           '^','&','(',')','_','=','/','\','<','>'];
  AllDelims : TSysCharSet =  ['.','!','?',
                           '-',',',':',';','+','*','~','`','@','#','$','%',
                           '^','&','(',')','_','=','/','\','<','>'];


const // tables
  cst_users = 'terra_users';
  cst_contactgroups = 'terra_ContactGroups';
  cst_contacts = 'terra_Contacts';
  cst_contactgrouptypes = 'terra_GroupTypes';
  cst_roles = 'terra_roles';
  cst_cities = 'terra_Cities';
  cst_countries = 'terra_Countries';
  cst_updates = 'terra_updates';
  cst_appointments = 'terra_Appointments';
  cst_ContactAppointments = 'terra_ContactsAppointments';
const
  SQL_MYSQL_GETCURDATE = cs_select+csS+'CURDATE()'+csS+cs_as+csS+'test';
  SQL_ORACLE_GETCURDATE = cs_select+csS+'SYSDATE'+csS+cs_as+csS+'test'+csS+cs_from+csS+'DUAL';
  SQL_MSSQL_GETCURDATE = cs_select+csS+'getdate()'+csS+cs_as+csS+'test';

  SQL_ACCES_S = '(ACCESS & %d)';
  SQL_ACCESS_LOW = '((ACCESS < %d) )';
  SQL_WITHOUT_DEL = '((DELETED = b''0'') AND ((DATEDEL = 0) OR (DATEDEL > CURRENT_TIMESTAMP) OR (DATEDEL is NULL)))';
  SQL_WHERE_NORMALREC_S = cs_where + csS + SQL_ACCES_S + csS + cs_and + csS + SQL_WITHOUT_DEL;
  SQL_GET_USERS = cs_select + csS + '*' + csS + cs_from + csS + cst_users
                  + csS + SQL_WHERE_NORMALREC_S
                  + csS + cs_order_by + csS + cs_login;
  SQL_GET_CONTACTGROUPS = cs_select + csS + '*' + csS + cs_from + csS + cst_contactgroups
                  + csS + SQL_WHERE_NORMALREC_S
                  + csS + cs_order_by + csS + cs_name;
  // SELECT *, @rowid:=@rowid+1 as rowid FROM terra_Contacts, (SELECT @rowid:=0) as init
  //SQL_GET_CONTACTS = 'SELECT *, @rowid:=@rowid+1 as rowid FROM terra_Contacts, (SELECT @rowid:=0) as init'
  //                + csS + SQL_WHERE_NORMALREC_S;
  SQL_GET_CONTACTS = cs_select + csS + '*' + csS + cs_from + csS + cst_contacts
                  + csS + SQL_WHERE_NORMALREC_S ;//+ csS + cs_order_by + csS + cs_name;
  SQL_GET_CONTACTGROUPTYPES =
                  cs_select + csS + '*' + csS + cs_from + csS + cst_contactgrouptypes
                  + csS + cs_order_by + csS + cs_name;
  SQL_GET_ACCESLIST_LOW =
                  cs_select + csS + '*' + csS + cs_from + csS + cst_roles
                  + csS + cs_where + csS+ SQL_ACCESS_LOW
                  ;//+ csS + cs_order_by + csS + cs_name;
  SQL_GET_CITIES = cs_select + csS + '*' + csS + cs_from + csS + cst_cities;
  SQL_GET_COUNTRIES = cs_select + csS + '*' + csS + cs_from + csS + cst_countries;
  SQL_GET_APPOINTMENTS = cs_select + csS + '*' + csS + cs_from + csS + cst_appointments;
  SQL_GET_APPOINTMENTS_OF_CONTACT = cs_select + csS + '*' + csS + cs_from + csS + cst_ContactAppointments
                      +csS + cs_where + csS + 'ContactID = %d';
  SQL_GET_UPDATES = cs_select + csS + 'id,version,filename' + csS + cs_from + csS + cst_updates
                  +csS + cs_where + csS + 'version = ''%s''';
  SQL_FILEDATA_FIELDNAME =  'filedata';
  SQL_GET_UPDATES_BY_ID = cs_select + csS + SQL_FILEDATA_FIELDNAME + csS + cs_from + csS + cst_updates
                  + csS + cs_where + csS + 'ID = %d';
  SQL_GET_ALL_VERSIONS ='Select id,version as name from ('
                          +'SELECT id, version, '
                          +'SUBSTRING_INDEX(version, ''.'', 1) as major, '
                          +'SUBSTRING_INDEX(SUBSTRING_INDEX(version, ''.'', 2),''.'',-1) as minor, '
                          +'SUBSTRING_INDEX(SUBSTRING_INDEX(version, ''.'', 3),''.'',-1) as Releas, '
                          +'SUBSTRING_INDEX(version, ''.'', -1) as build '
                          +'FROM `terra_updates` order by 3,4,5,6'
                          +') as t';
  SQL_GET_TO_MY_VERSION = cs_select + csS + SQL_FILEDATA_FIELDNAME + csS + cs_from + csS + cst_updates
                        + csS + cs_where + csS + 'TOVERSION = ''%S''';
  SQL_GET_MY_VERSION_EXISTS = cs_select + csS + 'TOVERSION' + csS + cs_from + csS + cst_updates
                        + csS + cs_where + csS + 'TOVERSION = ''%S''';
implementation

function MD5(S: String): String;
begin
  with TIdHashMessageDigest5.Create do
  begin
    Result := HashStringAsHex(S);
    DisposeOf;
  end;
end;

function NormalizePunktSpaces(s:string):string;
var i: NativeInt;
begin
  Result:=trim(DeleteDoubleSpaces(s));

  i := 1;
  while I <= Length(Result) do
  begin

    if CharInSet(Result[i],AllDelims) then
    begin
      Result := StringReplace(Result,csS+Result[i],Result[i],[rfReplaceAll]);
      //Result:= DeleteDoubleSpaces(Result);
      Result := StringReplace(Result,Result[i],Result[i]+csS,[rfReplaceAll]);
      Result:= DeleteDoubleSpaces(Result);
    end;
    inc(i);
  end;
  Result:=trim(Result);
end;

function AnsiOfferCase(const S: string; OfferDelims: TCharSet = ['.','!','?']): string;
var
  I: NativeInt;
  fNewOffer:boolean;
const
  WordDelims : TSysCharSet = [' ','-',',',':',';','+','*','~','`','@','#','$','%',
                           '^','&','(',')','_','=','/','\','<','>'];
begin
  Result := NormalizePunktSpaces(S);
  I := 1;

  fNewOffer := true;
  while I <= Length(Result) do
  begin
    if CharInSet(Result.Chars[I],OfferDelims) then
    begin
      fNewOffer := true;
      while CharInSet(Result.Chars[I],OfferDelims) do
        inc(i);
      while CharInSet(Result.Chars[I],WordDelims) do
        inc(i);
    end;

    if fNewOffer
    then
    begin
      Result[I] := AnsiUpperCase(Result[I])[1];
      fNewOffer := false;
    end;
    inc(i);
  end;
  Result := trim(Result);
  if not CharInSet(Result.Chars[I],OfferDelims) then Result := Result + '.';

end;

function AnsiProperCase(const S: string; const WordDelims: TCharSet = [' ',',']): string;
var
  SLen, I: NativeInt;
begin
  Result := AnsiLowerCase(S);
  I := 1;
  SLen := Length(Result);
  while I <= SLen do
  begin
    while (I <= SLen) and (CharInSet(Result.Chars[I],WordDelims)) do
      Inc(I);

    if I <= SLen
    then
      Result[I] := AnsiUpperCase(Result[I])[1];

    while (I <= SLen) and not (CharInSet(Result.Chars[I],WordDelims)) do
      Inc(I);
  end;
end;

function DeleteDoubleSpaces(s:string):string;
var tmp:string;
begin
  Result := Trim(s);
  tmp :=  stringreplace(Result,'  ',' ',[rfIgnoreCase,rfReplaceAll]);
  while Result <> tmp do
  begin
    Result := tmp;
    tmp :=  stringreplace(Result,'  ',' ',[rfIgnoreCase,rfReplaceAll]);
  end;
end;


function FormatOffer(offer:string):string;
begin
  Result := DeleteDoubleSpaces(offer);
  if length(Result)=0 then exit;
  Result := AnsiOfferCase(Result);
end;

function NewOffer(arr:array of string):string;
var
  i: NativeInt;
begin
  Result := '';
  for i := Low(arr) to High(arr) do
  begin
    Result := Result + csS + arr[i];
  end;
  Result :=  FormatOffer(trim(Result));
end;

function GetMyVersion:string;
type
  TVerInfo=packed record
    Nevazhno: array[0..47] of AnsiChar; // ненужные нам 48 байт
    Minor,Major,Build,Release: word; // а тут версия
  end;
var
  s:TResourceStream;
  v:TVerInfo;
begin
  result:='';
  try
    s:=TResourceStream.Create(HInstance,'#1',RT_VERSION); // достаём ресурс
    if s.Size>0 then
    begin
      s.Read(v,SizeOf(v)); // читаем нужные нам байты
      result:=IntToStr(v.Major)+'.'+IntToStr(v.Minor)+'.'+ // вот и версия...
              IntToStr(v.Release)+'.'+IntToStr(v.Build);
    end;
    s.Free;
  except;

  end;
end;

end.

