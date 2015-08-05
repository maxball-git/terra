unit uAppointmentViewForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uAppForm, uDB, uDBCustomObjects,
  Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls, uConsts;

type
  TDialogMode = (dmAdd,dmEdit,dmDel);

  TAppointmentViewForm = class(TAppForm)
    Panel1: TPanel;
    ledDescription: TLabeledEdit;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    lstEmployers: TListView;
    lstAppointments: TListView;
    btnAction: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Splitter1: TSplitter;
    lblTitle: TLabel;
    procedure btnCancelClick(Sender: TObject);
    procedure btnActionClick(Sender: TObject);
  protected
    { Private declarations }
    fDialogMode : TDialogMode;

    fDictEmployers:TDBContactsList;
    fDictAppointments:TDBAppointments;
    fContact:TDBContact;
    fAppointmentsList:TDBContactAppointments;
    fAppointment:TDBContactAppointment;

  public
    { Public declarations }
    constructor Create(aContact:TDBContact;
                       aAppointment:TDBContactAppointment);virtual;
    procedure FillDicts;
    procedure FillDictAppointments;
    procedure FillDictEmployers;
    property Contact:TDBContact read fContact;
    property Appointment:TDBContactAppointment read fAppointment;
  end;

implementation

{$R *.dfm}

{ TAppointmentViewForm }



procedure TAppointmentViewForm.btnActionClick(Sender: TObject);
begin
  inherited;
  if (lstEmployers.Selected<>nil)
    or (lstAppointments.Selected<>nil) then
  begin
    fAppointment.AppointmentID:=TDBIDObject(lstAppointments.Selected.Data).ID;
    fAppointment.CompanyID:=TDBIDObject(lstEmployers.Selected.Data).ID;
    fAppointment.Description:= ledDescription.Text;
    fAppointment.Write([]);
    ModalResult := mrOk;
  end;
end;

procedure TAppointmentViewForm.btnCancelClick(Sender: TObject);
begin
  inherited;
  if fDialogMode = dmAdd then
    fAppointmentsList.Query.Connection.ExecSQL('delete from '+cst_ContactAppointments+' where id = '+inttostr(fAppointment.ID));
end;

constructor TAppointmentViewForm.Create(aContact: TDBContact; aAppointment: TDBContactAppointment);
var LI:TListItem;
begin
  inherited Create(nil);
  fContact:= aContact;
  fAppointmentsList := TDBContactAppointments.Create(fContact);
  fDictAppointments := TDBAppointments.Create;
  fDictEmployers := TDBContactsList.Create;

  fAppointment := aAppointment;

  Caption := fContact.DisplayName;
  lblTitle.Caption := '';
  FillDicts;
  fDialogMode := dmDel;
  if not Assigned(fAppointment) then
  begin
    fDialogMode := dmAdd;
    Caption := 'Добавление места работы';
    lblTitle.Caption := fContact.DisplayName + ' - ' + '<новое место работы>';
    btnAction.Caption := 'Добавить';
    fAppointment := TDBContactAppointment.Create(fAppointmentsList.Query,-1,true,true);
    fAppointment.ContactID := fContact.ID;
    fAppointment.WriteField('ContactID');
    fAppointmentsList.LoadFromDB;
    //fAppointmentsList.Add(fAppointment);
  end
  else
  begin
    fDialogMode := dmEdit;
    Caption := 'Редактирование места работы';
    lblTitle.Caption := fContact.DisplayName + ' - ' + fAppointment.AppointmentName;
    btnAction.Caption := 'Применить';
    LI := TListItem(FindItemByID(fAppointment.AppointmentID,lstAppointments));
    if assigned(LI) then
      Li.Selected := true;
    LI := TListItem(FindItemByID(fAppointment.CompanyID,lstEmployers));
    if assigned(LI) then
      Li.Selected := true;
    ledDescription.Text := fAppointment.Description;
    ledDescription.SelLength := 0;
    ledDescription.SelStart := length(ledDescription.Text);
  end;


end;

procedure TAppointmentViewForm.FillDicts;
begin
  FillDictAppointments;
  FillDictEmployers;
end;

procedure TAppointmentViewForm.FillDictAppointments;
var i:NativeUInt;
begin
  lstAppointments.Clear;
  for i := 0 to fDictAppointments.Count-1 do
  begin
    with lstAppointments.Items do
    begin
      with Add do
      begin
        Data := fDictAppointments[i];
        Caption := TDBAppointment(fDictAppointments[i]).Name;
        SubItems.Append(TDBAppointment(fDictAppointments[i]).Description);
      end;
    end;
  end;
end;

procedure TAppointmentViewForm.FillDictEmployers;
var i:NativeUInt;
begin
  lstEmployers.Clear;
  for i := 0 to fDictEmployers.Count-1 do
  begin
    with lstEmployers.Items do
    begin
      with Add do
      begin
        Data := fDictEmployers[i];
        Caption := TDBContact(fDictEmployers[i]).DisplayName;
//        SubItems.Append(TDBContact(fDictEmployers[i]).Description);
      end;
    end;
  end;
end;

end.
