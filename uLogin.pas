unit uLogin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Menus, Vcl.ComCtrls,
  Vcl.AppEvnts, Vcl.CategoryButtons, Vcl.ButtonGroup, System.Actions,
  Vcl.ActnList, Clipbrd,

  uConsts, uDB, uDBCustomObjects, uLog, Vcl.StdCtrls;


type

  TLoginForm = class;

  TDBLoginUser = class(TDBObjectTable)
  private
    fLoginForm:TLoginForm;
  public
    constructor Create(LF:TLoginForm);virtual;
    procedure InitParams;override;
  end;

  TLoginForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Edit1: TEdit;
    Button1: TButton;
    Button2: TButton;
    Edit2: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    LoginUser: TDBLoginUser;
    function GetLogin: string;
    function GetPassword: string;
    procedure DebugTimer(Sender : TObject);
    { Private declarations }
  public
    { Public declarations }
    property Login: string read GetLogin;
    property Pasword: string read GetPassword;
    constructor Create(AOwner : TComponent);override;
  end;

var
  LoginForm: TLoginForm;

implementation

{$R *.dfm}

{ TDBLoginUser }

constructor TDBLoginUser.Create(LF: TLoginForm);
begin
  fLoginForm := LF;
  Inherited Create;
end;

procedure TDBLoginUser.InitParams;
var s:string;
begin
  s := Format(

  cs_select + csS + '*' + csS + cs_from + csS + cst_users
                  + csS + SQL_WHERE_NORMALREC_S + csS
                  + cs_and + csS + cs_login + '='''+fLoginForm.Login+'''' + csS
                  + cs_and + csS + cs_password + '='''+fLoginForm.Pasword+'''' + csS
                  + csS + cs_order_by + csS + cs_login

  ,[DBG_ALL]);
  fQuery.SQL.Text := s;
  fClass:=TDBUser;
end;

{ TLoginForm }

procedure TLoginForm.Button1Click(Sender: TObject);
begin
  LoginUser := TDBLoginUser.Create(self);
  try
    if LoginUser.Count >0 then
    begin
      CurrentUser := TDBUser(LoginUser.Items[0]);
      ModalResult := mrOk;
    end
    else
      ShowMessage('Не верное имя пользователя или пароль.');
  finally
    LoginUser.Free;
  end;
end;

constructor TLoginForm.Create(AOwner: TComponent);
begin
  inherited;

end;

procedure TLoginForm.DebugTimer(Sender: TObject);
begin
{$IFDEF DEBUG}
  edit2.Text:='Admin'; edit1.Text:='Fringes123#';
  //edit2.Text:='test'; edit1.Text:='test';

  TTimer(Sender).Enabled:=false;
  Button1Click(Button1);
{$ENDIF}
end;

procedure TLoginForm.FormShow(Sender: TObject);
begin
{$IFDEF DEBUG}
  with TTimer.Create(Self) do
  begin
    Interval := 100;
    OnTimer := DebugTimer;
  end;
{$ENDIF}
end;

function TLoginForm.GetLogin: string;
begin
  Result := Edit2.Text;
end;

function TLoginForm.GetPassword: string;
begin
  Result:=Edit1.Text;
  Result := MD5(Result);
{$IFDEF DEBUG}
//  Clipboard.AsText:=Result;
//  ShowMessage('Debug: "'+Result+'"');
{$ENDIF}
end;



end.
