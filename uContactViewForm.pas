unit uContactViewForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uLocalOptions,
  uLog, uConsts, uDB, uDBCustomObjects, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.CheckLst,
  TypInfo, uAppForm, VCL.ComCtrls, Googlemaps, Vcl.Menus, uFloatForm,
  Vcl.ToolWin, System.ImageList, Vcl.ImgList, System.Actions, Vcl.ActnList,
  uAppointmentViewForm;

type
  TContactViewForm = class(TAppForm)
    Panel1: TPanel;
    Panel2: TPanel;
    btnClose: TButton;
    btnSave: TButton;
    Panel3: TPanel;
    CategoryPanelGroup1: TCategoryPanelGroup;
    CategorySystem: TCategoryPanel;
    AutosizeBevelSystem: TBevel;
    pContactType: TPanel;
    Label1: TLabel;
    cbContactGroupType: TComboBox;
    pAccess: TPanel;
    Label3: TLabel;
    chbACCESS: TCheckListBox;
    Panel4: TPanel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    CategoryContacts: TCategoryPanel;
    AutosizeBevelContacts: TBevel;
    pEmail: TPanel;
    Label13: TLabel;
    eEmail: TEdit;
    pPhones: TPanel;
    Label14: TLabel;
    ePhones: TEdit;
    pFaxes: TPanel;
    Label15: TLabel;
    eFaxes: TEdit;
    pPost: TPanel;
    Label16: TLabel;
    ePost: TEdit;
    CategoryCommon: TCategoryPanel;
    AutosizeBevelCommon: TBevel;
    pFullName: TPanel;
    Label7: TLabel;
    eFullName: TEdit;
    pShortName: TPanel;
    Label8: TLabel;
    eShortName: TEdit;
    pAbbreviation: TPanel;
    Label9: TLabel;
    eAbbreviation: TEdit;
    pName: TPanel;
    Label10: TLabel;
    eName: TEdit;
    pSurname: TPanel;
    Label11: TLabel;
    eSurname: TEdit;
    pPatronymic: TPanel;
    Label12: TLabel;
    ePatronymic: TEdit;
    pContactGroup: TPanel;
    Label2: TLabel;
    cbContactGroup: TComboBox;
    TitlePanel: TPanel;
    TitleLabel: TLabel;
    RequestTimer: TTimer;
    cpAppointments: TCategoryPanel;
    lsAppoints: TListView;
    popAppointments: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    tbAppointments: TToolBar;
    CVFIL_Hot: TImageList;
    CVFIL_Norm: TImageList;
    CVFIL_Dis: TImageList;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ActionList1: TActionList;
    actAddAppointment: TAction;
    actEditAppointment: TAction;
    actDelAppointment: TAction;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CategorySystemExpand(Sender: TObject);
    procedure CategoryContactsExpand(Sender: TObject);
    procedure CategoryCommonExpand(Sender: TObject);
    procedure CatPanelCollapse(Sender: TObject);

    procedure ListPropChange(Sender: TObject);
    procedure EditPropChange(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure DoMoveForm(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RequestTimerTimer(Sender: TObject);
    procedure cpAppointmentsCollapse(Sender: TObject);
    procedure cpAppointmentsExpand(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure actAddAppointmentExecute(Sender: TObject);
    procedure actEditAppointmentExecute(Sender: TObject);
    procedure actDelAppointmentExecute(Sender: TObject);
    procedure ActionList1Update(Action: TBasicAction; var Handled: Boolean);
  private
    fContact: TDBContact;
    fGlobalLists : TList;
    fViewMode: TViewMode;
    fModifyList:TList;
    fFloatTimer:TTimer;
    procedure SetContact(const Value: TDBContact);
    { Private declarations }
    procedure ClearData;

    procedure ParseACCESS;
    procedure ParseData;
    procedure ParseCREATOR;
    procedure SetViewMode(const Value: TViewMode);
    procedure FloatMenuTimerTimer(Sender: TObject);
    
  public
    { Public declarations }
    property ViewMode:TViewMode read fViewMode write SetViewMode;
    property Contact:TDBContact read fContact write SetContact;
    procedure CatGroupSaveState(Cp:TCategoryPanel);

    procedure ParseListProperty(SQL:string;CB:TComboBox;PropertyName:string);
    procedure ParseStringProperty(Ed:TEdit;PropertyName:string);
    procedure ParseAppointments;

    procedure SetProperty(Value:variant; PropName: string);
    procedure SetCaption(s:string);

    function ActionIfModified:integer;
    function ExistsInGlobal(BDClass:TDBObjectClass):boolean;
  end;


  PGeoRec = ^TGeoRec;
  TGeoRec = record
    Comp:TComponent;
    Prop:string;
  end;


  PModifyAction = ^TModifyAction;
  TModifyAction = record
    PropName:string;
    OldValue:Variant;
    NewValue:Variant;
  end;

var MessageDispatcher : THandle;

implementation

{$R *.dfm}
uses
  uMain_win;

procedure TContactViewForm.FloatMenuTimerTimer(Sender: TObject);
begin

end;

procedure TContactViewForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  ClearData;
  fGlobalLists.Free;
  fModifyList.Free;
  if RequestTimer.Tag<>0 then
    FreeMem(PGeoRec(RequestTimer.Tag));
end;

procedure TContactViewForm.ClearData;
var i:integer;
begin
  for i := 0 to fGlobalLists.Count - 1 do
  begin
    DestroyDBList(TList(fGlobalLists[i]));
  end;
  for i := 0 to fModifyList.Count - 1 do
  begin
    FreeMem(fModifyList[i],SizeOf(TModifyAction)) ;
  end;
end;

procedure TContactViewForm.cpAppointmentsCollapse(Sender: TObject);
begin
  CatGroupSaveState(TCategoryPanel(Sender));
end;

procedure TContactViewForm.cpAppointmentsExpand(Sender: TObject);
begin
  //ParseStringProperty(ePhones,'Phones');
  ParseAppointments;
  CatGroupSaveState(TCategoryPanel(Sender));
end;

procedure TContactViewForm.FormCreate(Sender: TObject);
var h, i :integer;
begin
  fGlobalLists := TList.Create;
  fModifyList := TList.Create;
  if GlassFrame.Enabled then
  begin
    h := GetSystemMetrics(SM_CYCAPTION);
    GlassFrame.Left := h - BorderWidth;
    GlassFrame.Top := 0; //h - BorderWidth;
    GlassFrame.Right := h - BorderWidth;
    GlassFrame.Bottom := h - BorderWidth;
    Padding.Top := 0;
    Padding.Left := GlassFrame.Left + BorderWidth;
    Padding.Right := GlassFrame.Right + BorderWidth;
    Padding.Bottom := GlassFrame.Bottom + BorderWidth;
  end;
  for i := 0 to CategoryPanelGroup1.Panels.Count-1 do
  begin
    TCategoryPanel(CategoryPanelGroup1.Panels[i]).OnCollapse := nil;
    if TCategoryPanel(CategoryPanelGroup1.Panels[i]).Collapsed = false then
        TCategoryPanel(CategoryPanelGroup1.Panels[i]).Collapsed := true;
    TCategoryPanel(CategoryPanelGroup1.Panels[i]).OnCollapse:=CatPanelCollapse;
  end;
end;

procedure TContactViewForm.FormResize(Sender: TObject);
begin
  TitleLabel.WordWrap:=false;
  TitleLabel.WordWrap:=true;

end;

procedure TContactViewForm.SetCaption(s: string);
begin
  Caption := s;
  TitlePanel.Caption := s;
end;

procedure TContactViewForm.SetContact(const Value: TDBContact);
begin
  fContact := Value;
  if not Assigned(fContact) then
  begin
    exit;
  end;
  ClearData;
  ParseData;
end;

procedure TContactViewForm.SetViewMode(const Value: TViewMode);
begin
  fViewMode := Value;
  eFullName.ReadOnly := fViewMode = vmView;
  eShortName.ReadOnly := fViewMode = vmView;
  eAbbreviation.ReadOnly := fViewMode = vmView;
  eName.ReadOnly := fViewMode = vmView;
  eSurname.ReadOnly := fViewMode = vmView;
  ePatronymic.ReadOnly := fViewMode = vmView;
  eEmail.ReadOnly := fViewMode = vmView;
  ePhones.ReadOnly := fViewMode = vmView;
  eFaxes.ReadOnly := fViewMode = vmView;
  ePost.ReadOnly := fViewMode = vmView;
  cbContactGroup.Enabled := fViewMode = vmEdit;
  cbContactGroupType.Enabled := fViewMode = vmEdit;
  chbACCESS.Enabled := fViewMode = vmEdit;
  //lsAppoints.ReadOnly := fViewMode = vmView;
  btnSave.Visible := fViewMode = vmEdit;
end;

procedure TContactViewForm.ParseData;
var i:integer;
begin

  case fViewMode of
    vmView: SetCaption('Просмотр контакта');
    vmEdit: SetCaption('Редактирование контакта');
  end;
  SetCaption(Caption + ': "' + fContact.DisplayName);
  with TOptions.Create do
  begin
    for i := 0 to CategoryPanelGroup1.Panels.Count-1 do
      if ReadBool(Self.ClassName,TCategoryPanel(CategoryPanelGroup1.Panels[i]).Name,False)
      then
      begin
        if TCategoryPanel(CategoryPanelGroup1.Panels[i]).Collapsed = false then
          TCategoryPanel(CategoryPanelGroup1.Panels[i]).Collapsed := true;
        TCategoryPanel(CategoryPanelGroup1.Panels[i]).Expand;
      end;
  end;
end;

procedure TContactViewForm.CatGroupSaveState(Cp: TCategoryPanel);
begin
  with TOptions.Create do
  begin
    WriteBool(Self.ClassName,Cp.Name,not Cp.Collapsed);
    Free;
  end;
end;

procedure TContactViewForm.CatPanelCollapse(Sender: TObject);
begin
  CatGroupSaveState(TCategoryPanel(Sender));
end;

procedure TContactViewForm.CategorySystemExpand(Sender: TObject);
begin
  ParseACCESS;
  ParseCREATOR;
  CategorySystem.Height := CategoryPanelGroup1.HeaderHeight + AutosizeBevelSystem.Top+2;
  CatGroupSaveState(TCategoryPanel(Sender));
end;

function TContactViewForm.ActionIfModified:integer;
var s:String;
    i: integer;
begin
  s:= '';
  if fModifyList.Count = 0 then
  begin
    Result := ID_NO;
    exit;
  end;
  for i := 0 to fModifyList.Count - 1 do
  begin
    s:=s+PModifyAction(fModifyList[i]).OldValue + ' -> ' + PModifyAction(fModifyList[i]).NewValue +#13#10;
  end;
  s:= 'Полученные изменения:'+#13#10+s+'Сохранить?';
  Result := MessageBox(self.Handle,PWideChar(s),'Данные изменены',MB_YESNOCANCEL);
end;

procedure TContactViewForm.ActionList1Update(Action: TBasicAction;
  var Handled: Boolean);
var b:boolean;
begin
  inherited;
  b := (lsAppoints.Selected <> nil) and lsAppoints.Selected.Focused;
  actDelAppointment.Enabled := b;
  actEditAppointment.Enabled := b;
  actAddAppointment.Enabled := GetCurrentRole > 1;
end;

procedure TContactViewForm.btnCloseClick(Sender: TObject);
var mr :integer;
begin
  mr := ActionIfModified;
  if mr = ID_YES then
  begin
    btnSave.Click;
    free;
  end
  else
  if mr = ID_NO then
    Free
end;

procedure TContactViewForm.btnSaveClick(Sender: TObject);
var i:integer;
begin
  try
    fContact.Write([]);
    for i := 0 to fModifyList.Count - 1 do
    begin
      freemem(PModifyAction(fModifyList[i]))
    end;
    fModifyList.Clear;
  except

  end;
  SendMessage(TTabSheet(Owner).handle,WM_User+3,0,fContact.ID);
end;

procedure TContactViewForm.CategoryCommonExpand(Sender: TObject);
begin
  ParseListProperty(SQL_GET_CONTACTGROUPTYPES,cbContactGroupType,'GroupType');
  ParseListProperty(Format(SQL_GET_CONTACTGROUPS,[GetCurrentRole]),cbContactGroup,'GroupID');
  case fContact.GroupType of
    0:begin
        pName.Hide;
        pPatronymic.Hide;
        pSurname.Hide;

        pAbbreviation.Show; pAbbreviation.Top := -1;
        pShortName.Show; pShortName.Top := -1;
        pFullName.Show; pFullName.Top := -1;

        ParseStringProperty(eFullName,'FullName');
        ParseStringProperty(eShortName,'ShortName');
        ParseStringProperty(eAbbreviation,'Abbreviation');


      end;
    1:begin
        pSurname.Show; pSurname.Top := -1;
        pPatronymic.Show; pPatronymic.Top := -1;
        pName.Show; pName.Top := -1;

        pAbbreviation.Hide;
        pShortName.Hide;
        pFullName.Hide;
        ParseStringProperty(eName,'Name');
        ParseStringProperty(eSurname,'Surname');
        ParseStringProperty(ePatronymic,'Patronymic');
      end;
  end;
  pContactGroup.Top := -1;
  CategoryCommon.Height := CategoryPanelGroup1.HeaderHeight + AutosizeBevelCommon.Top+2;

  CatGroupSaveState(TCategoryPanel(Sender));
end;

procedure TContactViewForm.CategoryContactsExpand(Sender: TObject);
begin
  ParseStringProperty(ePhones,'Phones');
  ParseStringProperty(ePost,'Post');
  ParseStringProperty(eFaxes,'Faxes');
  ParseStringProperty(eEmail,'Email');

  CategoryContacts.Height := CategoryPanelGroup1.HeaderHeight + AutosizeBevelContacts.Top+2;
  CatGroupSaveState(TCategoryPanel(Sender));
end;

procedure TContactViewForm.ParseACCESS;
var l:TDBDictionary;
    i,c:integer;
    s:String;
begin
  s := Format(SQL_GET_ACCESLIST_LOW,[GetCurrentRole]);
  l := TDBDictionary.Create(s,TDBAcces);
  fGlobalLists.Add(l);
  chbACCESS.Items.BeginUpdate;
  chbACCESS.Items.Clear;
  for i := 0 to l.Count - 1 do
  begin
    c:=chbACCESS.Items.AddObject(TDBAcces(l[i]).Name,TDBAcces(l[i]));
    if (fContact.ACCESS and TDBAcces(l[i]).ACCESS)<>0  then
    chbACCESS.Checked[c]:=true;
  end;
  chbACCESS.Items.EndUpdate;
end;


procedure TContactViewForm.ParseCREATOR;
var US:TDBUsers;
    U:TDBUser;
begin
  if fContact.DATECREATE <> 0 then
    Label5.Caption := 'Когда: ' + FormatDateTime('ddd d.mm.yyyy hh:nn:ss',fContact.DATECREATE)
  else
    Label5.Caption := 'Когда: Не определено';
  US:=TDBUsers.Create;
  fGlobalLists.Add(US);
  try
    U:= TDBUser(US.ByID[fContact.CREATOR]);
    if assigned(U) then
      Label6.Caption := 'Кем: ' + U.Login
    else
      Label6.Caption := 'Кем: Не определено'
  except

  end;
end;


procedure TContactViewForm.ParseStringProperty(Ed: TEdit; PropertyName: string);
var OnChangeOld : TNotifyEvent;
begin
  OnChangeOld := Ed.OnChange;
  Ed.OnChange := nil;
  Ed.Text := GetPropValue(fContact,PropertyName);
  Ed.OnChange := EditPropChange;
end;


procedure TContactViewForm.ParseListProperty(SQL:string;CB:TComboBox;PropertyName:string);
var OnChangeOld : TNotifyEvent;
    l:TDBDictionary;
    i,c:integer;
begin
  OnChangeOld := CB.OnChange;
  CB.OnChange := nil;
  CB.Items.BeginUpdate;
  CB.Items.Clear;
  l := TDBDictionary.Create(SQL,TDB_ID_NAME_Object);
  fGlobalLists.Add(l);
  for i := 0 to l.Count - 1 do
  begin
    c := CB.Items.AddObject(TDB_ID_NAME_Object(l[i]).Name,TDB_ID_NAME_Object(l[i]));
    if TDB_ID_NAME_Object(l[i]).ID = GetPropValue(fContact,PropertyName) then
     CB.ItemIndex := c;
  end;
  CB.Items.EndUpdate;
  CB.OnChange := ListPropChange;
end;

procedure TContactViewForm.DoMoveForm(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  ReleaseCapture;
  Perform ( WM_SYSCOMMAND, SC_MOVE+2, 0 );
end;

procedure TContactViewForm.ListPropChange(Sender: TObject);
var Prop:string;
begin
  prop := '';
  if sender = cbContactGroup then prop := 'GroupID' else
  if sender = cbContactGroupType then prop := 'GroupType';

  if length(prop) >0  then
    SetProperty(TDBIDObject(TComboBox(Sender).Items.Objects[TComboBox(Sender).ItemIndex]).ID,
                 'prop')
end;



procedure TContactViewForm.SetProperty(Value:variant; PropName: string);
var PM:PModifyAction;
    OldVal: Variant;
    i: Integer;
    mf: integer;
begin
  OldVal := GetPropValue(fContact,PropName);
  if OldVal <> Value then
  begin
    try
      SetPropValue(fContact,PropName,Value);
      mf := -1;
      for i := 0 to fModifyList.Count - 1 do
      begin
        if PModifyAction(fModifyList[i]).PropName = PropName then
          mf := i;
      end;
      if mf > -1 then
      begin
        with PModifyAction(fModifyList[mf])^ do
        begin
          NewValue := Value;
        end;
      end
      else
      begin
        PM := AllocMem(SizeOf(PM^));
        try
          PM.PropName := PropName;
          PM.NewValue := Value;
          PM.OldValue := OldVal;
          fModifyList.Add(PM);
        except
          FreeMem(PM,SizeOf(PM^));
        end;
      end;
    except

    end;
  end;
end;



procedure TContactViewForm.EditPropChange(Sender: TObject);
var Prop:string;
    PG : PGeoRec;
begin
  prop := '';
  if sender = eFullName then prop := 'FullName' else
  if sender = eShortName then prop := 'ShortName' else
  if sender = eAbbreviation then prop := 'Abbreviation' else
  if sender = eName then prop := 'Name';
  if sender = eSurname then prop := 'Surname' else
  if sender = ePatronymic then prop := 'Patronymic' else
  if sender = eEmail then prop := 'Email' else
  if sender = ePhones then prop := 'Phones';
  if sender = eFaxes then prop := 'Faxes' else
  if sender = ePost then
  begin
    RequestTimer.Enabled := false;
    RequestTimer.Free;
    RequestTimer := TTimer.Create(nil);
    RequestTimer.Interval := 2500;
    RequestTimer.OnTimer := RequestTimerTimer;

    prop := 'Post';
    if RequestTimer.Tag = 0 then
    begin
      PG := AllocMem(sizeOf(TGeoRec));
      RequestTimer.Tag := integer(PG)
    end
    else
      PG := Pointer(RequestTimer.Tag);
    PG.Comp := TEdit(Sender);
    PG.Prop := prop;
    exit;
  end;

  if Length(prop) >0 then
    SetProperty(TEdit(Sender).Text,prop);
end;


function TContactViewForm.ExistsInGlobal(BDClass: TDBObjectClass): boolean;
var
  i: Integer;
begin
  Result := false;
  for i := 0 to fGlobalLists.Count - 1 do
  begin
    if TObject(fGlobalLists[i]) is BDClass then
    begin
      result := true;
      exit;
    end;

  end;

end;

procedure TContactViewForm.RequestTimerTimer(Sender: TObject);
var Edit:TEdit;
    s:string;
    GM:TGMGeocodeResponse;
    PG : PGeoRec;
begin
  RequestTimer.Enabled := False;
  PG := pointer(TTimer(Sender).tag);
  Edit := TEdit(PG.Comp);
  s:=Edit.Text;
  GM := TGMGeocodeResponse.Create(s);
  if gm.ResultsCount > 0 then
  begin
    Edit.OnChange := nil;
    Edit.Text := gm.Results[0].FormattedAddress;
    SetProperty(gm.Results[0].FormattedAddress,PG.Prop);
    Edit.OnChange := EditPropChange;
  end;
  GM.Free;
end;

procedure TContactViewForm.ParseAppointments;
var Ap:TDBContactAppointments;
    iA:TDBContactAppointment;
    Cur:integer;
    i: Integer;
    LI:TListItem;
    s:string;
begin
  AP := TDBContactAppointments.Create(fContact);
  if AP.Count =0 then
  begin
    DestroyDBList(AP);
    exit
  end;
  fGlobalLists.Add(AP);
  lsAppoints.Enabled := false;
  lsAppoints.Items.BeginUpdate;
  try
    if lsAppoints.ItemIndex>=0 then
      Cur := TDBContactAppointment(lsAppoints.Items[lsAppoints.ItemIndex].Data).ID;
    lsAppoints.Items.Clear;

    for i := 0 to ap.Count - 1 do
    begin
      iA := ap[i];
      Li := lsAppoints.Items.Add;
      if iA.ID = Cur then
      begin
        Li.Selected:=true;
        Li.Focused := true;
      end;
      Li.Data := iA;


      Li.Caption := ia.AppointmentName;
      Li.SubItems.AddObject(iA.EmployerName,ia.EmployerDictobject);
      s:='';
      if Trim(iA.Description).Length > 0 then
        s:= Trim(iA.Description);
      if assigned(iA.AppointmentDictObject) then
      if Trim(iA.AppointmentDictObject.Description).Length >0 then
      begin
        if s.Length > 0 then
          s := s + '; ' + iA.AppointmentDictObject.Description
        else
          s := iA.AppointmentDictObject.Description
      end;
      Li.SubItems.Append(s);
    end;
  except

  end;
  lsAppoints.Items.EndUpdate;
  lsAppoints.Enabled := true;

end;


procedure TContactViewForm.actAddAppointmentExecute(Sender: TObject);
var LI:TListItem;
begin
  inherited;
  with TAppointmentViewForm.Create(fContact, nil) do
  begin
    if ShowModal = mrOk then
    begin
      ParseAppointments;
      LI := TListItem(FindItemByID(Appointment.ID,lsAppoints));
      if assigned(LI) then
        LI.Selected := true;
    end;
  end;
end;

procedure TContactViewForm.actDelAppointmentExecute(Sender: TObject);
begin
  inherited;
  ParseAppointments;
end;

procedure TContactViewForm.actEditAppointmentExecute(Sender: TObject);
var LI:TListItem;
begin
  inherited;
  with TAppointmentViewForm.Create(fContact,TDBContactAppointment(lsAppoints.Selected.Data)) do
  begin
    if ShowModal = mrOk then
    begin
      ParseAppointments;
      LI := TListItem(FindItemByID(Appointment.ID,lsAppoints));
      if assigned(LI) then
        LI.Selected := true;
    end;
  end;
end;
end.
