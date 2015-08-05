unit uUpdater;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Winapi.ShellApi, Forms, uDB, uConsts, uDBCustomObjects,
  Data.DB, uLog, uAwaitingForm;

  procedure DoSelfUpdate;
  function DownloadLaterVersion(var FN:string):boolean;
  procedure Executelater(FN:string; WithUpdateKey:boolean);
  procedure ReplaceOnSelf(older:string);
  procedure DoUploadSelf;

implementation

procedure DoSelfUpdate;
var
  fn : string;
  older : string;
begin
  Log.Write(LD_Application,NewOffer([cs_start,cs_application,cs_update,cs_procedure]));
  if ParamCount>0 then
  begin
    // если меня запустили с ключом для обновления
    if Pos(UpperCase('-'+csk_YOULATER),UpperCase(ParamStr(1))) > 0  then
    begin
      with TAwaitingForm.Create('Update program','Please wait') do
      begin
        Show;
        Enabled:=false;
        Log.Write(NewOffer([cs_exist,cs_command,UpperCase(ParamStr(1))]));
        // я немного подожду ... примерно три секунды
        try
          sleep(3000);
          // а теперь я должна стать другой ...
          older := trim(ParamStr(1).Split(['='])[1]);
          if FileExists(older) then
          begin
            ReplaceOnSelf(older);
            // и запустить себя в новом качестве без ключей
            Executelater(fn,false);
            // а сама сдохнуть
            try
              Log.Write(NewOffer([cs_application, cs_exit]));
              Application.Terminate;
            except

            end;
            Halt;
          end;
        except
          Log.Write(NewOffer([cs_exception,cs_on, cs_application, cs_update]));
        end;
        Free;
      end;
    end;
  end
  else
  // если без ключей, то я проверю обновления

  if DownloadLaterVersion(fn) then
  begin
  // если есть новый файл, то я его запущу с нужным ключом
    Executelater(fn,true);
    // и сдохну
    try
      Application.Terminate;
    except

    end;
    Halt;
  end
end;

procedure Executelater(FN:string; WithUpdateKey:boolean);
var pfn,params:PAnsiString;
begin
  try
    Log.Write(NewOffer([cs_do,cs_execute,cs_old,cs_file,FN]));
    pfn:=PAnsiString(ansistring(FN));
    if WithUpdateKey then
      params := PAnsiString('-YOULATER='+Paramstr(0))
    else
      params := nil;
    ShellExecuteA(0,
                'open',
                PAnsiChar(pfn),
                PAnsiChar(params),
                nil,
                SW_SHOWNORMAL);
  except
    Log.Write(NewOffer([cs_exception]));
  end;
end;

procedure ReplaceOnSelf(older:string);
var new:PAnsiString;
    old:PAnsiString;
begin
  try
    Log.Write(NewOffer([cs_do,cs_replace,cs_old,cs_file,older]));
    old := PAnsiString(AnsiString(older));
    new := PAnsiString(AnsiString(paramstr(0)));
    if DeleteFile(older) then
    begin
      if CopyFileA(PAnsiChar(old),PAnsiChar(new),false) then
        Log.Write(NewOffer([cs_error]))
      else
        Log.Write(NewOffer([cs_successfully]));
    end;
  except
    Log.Write(NewOffer([cs_exception,cs_replace,cs_old,cs_file,older]));
  end;
end;

function DownloadLaterVersion(var FN:string):boolean;
var
  DBUpdates : TDBUpdates;
  Rec:TDBUpdateRec;
  i:integer;
begin
  // поглядим в базу данных и попробуем определить
  // есть ли для меня новые файлы
  Result := false;
  Log.Write(NewOffer([cs_do,cs_procedure, cs_update, cs_application]));
  DBUpdates := TDBUpdates.Create;
  try
    if DBUpdates.Count=0 then
    begin
    // обновлений нет... но ... вдруг я совсем новее чем всё что там есть
      DoUploadSelf;
    end
    else
    begin
      Result := true;
      for i := 0 to DBUpdates.Count - 1 do
      begin
        Rec := TDBUpdateRec(DBUpdates[i]);
        try
          Rec.FILEDATA.SaveToFile(ExtractFilePath(Application.ExeName)+Rec.FILENAME);
        except
          Result := false;
          Log.Write(NewOffer([cs_exception, cs_download, cs_file, Rec.FILENAME]));
        end;
        Result := Result and true;
      end;
    end;
  except
    Log.Write(NewOffer([cs_exception,cs_procedure, cs_update]));
  end;
  DestroyDBList(DBUpdates);
end;

function GetLastVersionINDB:string;
var q:TQuery;
    l:TList;
    s:string;
begin
  s:=
  'Select id,toversion as version from ('
                          +'SELECT id,toversion, '
                          +'SUBSTRING_INDEX(toversion, ''.'', 1) as major, '
                          +'SUBSTRING_INDEX(SUBSTRING_INDEX(toversion, ''.'', 2),''.'',-1) as minor, '
                          +'SUBSTRING_INDEX(SUBSTRING_INDEX(toversion, ''.'', 3),''.'',-1) as Releas, '
                          +'SUBSTRING_INDEX(toversion, ''.'', -1) as build '
                          +'FROM `terra_updates` order by 3,4,5,6'
                          +') as t'
                          ;
  q:= NewQuery(s);
  l:= DBGet_ObjectList(TDBUpdateRec,q);
  q.Free;
  Result:=trim(TDBUpdateRec(l[l.Count-1]).VERSION);
  DestroyDBList(l);
end;

procedure DoUploadSelf;
var q:TQuery;
    l:TList;
   // FS:TFileStream;
    s:string;
begin
{$IFDEF DEBUG}
  q:=NewQuery(Format(SQL_GET_MY_VERSION_EXISTS,[getMyVersion]));
  if q.RecordCount>0 then
  begin
    q.Free;
    exit;
  end;
  q.Free;
  q:=NewQuery(Format(SQL_GET_TO_MY_VERSION,[getMyVersion]));
  l:= DBGet_ObjectList(TDB_ID_NAME_Object,q);
  with l do
  begin
    if Count = 0 then
    if MessageBox(0,'Залить новую версию?','Добавление новой версии программы',MB_YESNO) = ID_YES then
    begin
      with  TQuery.Create(nil) do
      begin
        Connection := uDB.Connection;
        s:= 'INSERT into '+cst_updates+csS+'(version,toversion,filename,filedata) values ('
         +'''' +GetLastVersionINDB+'''' +', '+'''' +GetMyVersion+'''' +', '''+ExtractFileName(Application.ExeName)+''', :FD)';
        SQL.Text := s;
        CopyFile(PWideChar(Application.ExeName),PWideChar(Application.ExeName+'_'),false);
        //FS:=TFileStream.Create(Application.ExeName+'_',fmOpenRead);
        Params.ParamByName('FD').LoadFromFile(Application.ExeName+'_',ftBlob);
        //FS.Free;
        ExecSQL;
        free;
      end;
    end;
    DestroyDBList(l);
  end;
{$ENDIF}
end;

end.
