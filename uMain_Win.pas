unit uMain_Win;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Menus, Vcl.ComCtrls,
  Vcl.AppEvnts, Vcl.CategoryButtons, Vcl.ButtonGroup, System.Actions,
  Vcl.ActnList,


  uLog, uConsts, uDB, uLogin, uDBCustomObjects,uAppTabSheet,
  uContacts, uProducts, uLocalOptions, uAppForm, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.UI.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef;

type
  TMainForm = class(TAppForm)
    Splitter1: TSplitter;
    PageControl1: TPageControl;
    ApplicationEvents1: TApplicationEvents;
    CategoryButtons1: TCategoryButtons;
    ActionList: TActionList;
    actNews: TAction;
    actLogin: TAction;
    actContacts: TAction;
    actProducts: TAction;
    actUsers: TAction;
    actAccess: TAction;
    actChangeRole: TAction;
    procedure ApplicationEvents1ActionExecute(Action: TBasicAction;
      var Handled: Boolean);
    procedure ApplicationEvents1Activate(Sender: TObject);
    procedure ApplicationEvents1Deactivate(Sender: TObject);
    procedure ApplicationEvents1Minimize(Sender: TObject);
    procedure ApplicationEvents1ShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
    procedure ApplicationEvents1Restore(Sender: TObject);
    procedure ApplicationEvents1SettingChange(Sender: TObject; Flag: Integer;
      const Section: string; var Result: Integer);
    function ApplicationEvents1Help(Command: Word; Data: NativeInt;
      var CallHelp: Boolean): Boolean;
    procedure ApplicationEvents1Hint(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
    procedure actLoginExecute(Sender: TObject);
    procedure actLoginExitExecute(Sender: TObject);
    procedure actContactsExecute(Sender: TObject);
    procedure actProductsExecute(Sender: TObject);
    procedure actChangeRoleExecute(Sender: TObject);
  private
    fAllMessagesToLog: Boolean;
    { Private declarations }
    procedure DoLoginAccepted;
    procedure DoLogOut;
  public
    { Public declarations }
    property AllMessagesToLog: Boolean read fAllMessagesToLog write fAllMessagesToLog;
    constructor Create(AOwner:TComponent);override;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.actLoginExitExecute(Sender: TObject);
begin
  if MessageBox(0,'Выход пользователя из базы?','sdf',MB_YESNO) = ID_YES then
  begin
    DoLogOut;
    actLogin.Caption := 'Вход';
    actLogin.OnExecute := actLoginExecute;
  end;
end;




procedure TMainForm.actLoginExecute(Sender: TObject);
var MR : TModalResult;
begin
  with TLoginForm.Create(nil) do
  begin
    MR := ShowModal;
    Free;
  end;
  if MR = mrOk then
  begin
    if Assigned(CurrentUser) then
    begin
      actLogin.Caption := 'Выход ('+CurrentUser.Login
        {$IFDEF DEBUG}
        +' DEBUG'
        {$ENDIF}
        + ')';
      actLogin.OnExecute := actLoginExitExecute;
    end;
    DoLoginAccepted;
  end
  else
  if MR = mrAbort then
  begin
    Application.Terminate;
  end;

end;

procedure TMainForm.ApplicationEvents1ActionExecute(Action: TBasicAction;
  var Handled: Boolean);
begin
  Log.Write(LD_Application,NewOffer([cs_start,cs_action,Action.Name+'('+Action.ClassName+')', cs_from, Action.ActionComponent.Name]));
end;

procedure TMainForm.ApplicationEvents1Activate(Sender: TObject);
begin
  Log.Write(LD_Application,NewOffer([cs_application, cs_activate]));
end;

procedure TMainForm.ApplicationEvents1Deactivate(Sender: TObject);
begin
  Log.Write(LD_Application,NewOffer([cs_application, cs_deactivate]));
end;

procedure TMainForm.ApplicationEvents1Exception(Sender: TObject; E: Exception);
begin
  Log.Write(LD_Application,NewOffer([cs_application, cs_exception,E.Message]));
end;

function TMainForm.ApplicationEvents1Help(Command: Word; Data: NativeInt;
  var CallHelp: Boolean): Boolean;
begin
  Result := true;
  Log.Write(LD_Application,NewOffer([cs_application, cs_help]));
end;

procedure TMainForm.ApplicationEvents1Hint(Sender: TObject);
begin
  Log.Write(LD_Application,NewOffer([cs_application, cs_hint]));
end;

procedure TMainForm.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
  if fAllMessagesToLog then
    Log.Write(LD_Application,NewOffer([cs_application, 'HWND', inttostr(msg.hwnd),
                                       cs_message,'=', inttostr(msg.message),
                                       'lParam=', inttostr(msg.lParam),
                                       'wParam=', inttostr(msg.wParam)]));
end;

procedure TMainForm.ApplicationEvents1Minimize(Sender: TObject);
begin
  Log.Write(LD_Application,NewOffer([cs_application, cs_minimize]));
end;

procedure TMainForm.ApplicationEvents1Restore(Sender: TObject);
begin
  Log.Write(LD_Application,NewOffer([cs_application, cs_restore]));
end;

procedure TMainForm.ApplicationEvents1SettingChange(Sender: TObject;
  Flag: Integer; const Section: string; var Result: Integer);
begin
  Log.Write(LD_Application,NewOffer([cs_application, cs_settings, cs_change, cs_flag, '=', inttostr(Flag),';',cs_section,'=', Section,';', cs_value,'=', inttostr(Result)]));
end;

procedure TMainForm.ApplicationEvents1ShortCut(var Msg: TWMKey;
  var Handled: Boolean);
begin
  Log.Write(LD_Application,NewOffer([cs_application, 'ShortCut',ShortCutToText(Msg.CharCode)]));
end;

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited;
  fAllMessagesToLog := false;
  actChangeRole.ActionComponent := Application;
end;

procedure TMainForm.DoLoginAccepted;
var
  i: Integer;
begin
  Cursor := crAppStart;
  Application.ProcessMessages;
  try
    for i := 0 to PageControl1.PageCount-1 do
    begin
      TAppTabSheet(PageControl1.Pages[i]).UpdateComponents;
    end;
  except

  end;
  sleep(500);
  Cursor := crDefault;
  Application.ProcessMessages;
end;

procedure TMainForm.DoLogOut;
begin
  FreeAndNil(CurrentUser);
end;

procedure TMainForm.actChangeRoleExecute(Sender: TObject);
begin
  //
  if (not Assigned(CurrentUser))
    and (GetCurrentRole < $7FFFFFFFFFFFFFFF)
  then
    showMessage('Вы не можете сменить свою роль')
  else
    CurrentUser.role := strtoint64(inputbox('Смена роли','Новая роль:','1'));
end;

procedure TMainForm.actContactsExecute(Sender: TObject);
var TS : TContactsSheet;
begin
  TS := TContactsSheet(PageControl1.FindChildControl('ContactsSheet'));
  if not Assigned(TS) then
  begin
    TS := TContactsSheet.Create(PageControl1);
    TS.Name := 'ContactsSheet';
    TS.PageControl := PageControl1;
    PageControl1.ActivePage := TS;
  end
  else
  begin
    PageControl1.ActivePage := TS;
    Application.ProcessMessages;
    TS.UpdateComponents;
  end;

end;

procedure TMainForm.actProductsExecute(Sender: TObject);
var TS : TProductSheet;
begin
  TS := TProductSheet(PageControl1.FindChildControl('ProductSheet'));
  if not Assigned(TS) then
  begin
    TS := TProductSheet.Create(PageControl1);
    TS.Name := 'ProductSheet';
    TS.PageControl := PageControl1;
  end;
  PageControl1.ActivePage := TS;
end;

end.
