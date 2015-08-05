unit uContacts;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Menus, Vcl.ComCtrls,
  Vcl.AppEvnts, Vcl.CategoryButtons, Vcl.ButtonGroup, System.Actions,
  Vcl.ActnList, Vcl.StdCtrls,
  uLog, uConsts, uDB, uLogin, uDBCustomObjects, uAppTabSheet,
  uContactViewForm;
type

  TContactsSheet = class(TAppTabSheet)
  private
    fContactList: TListView;
    fSplitter: TSplitter;
    fGroupList: TTreeView;
    fDBContactGroups: TDBContactsGroups;
    fDBContactsList : TDBContactsList;
    fGroupsPopup,
    fContactsPopup:TPopupMenu;
  public
    constructor Create(AOwner: TComponent); override;

    procedure WM_UPDATE_ALL(var msg:TMessage); message WM_USER+1;
    procedure WM_UPDATE_GROUPS(var msg:TMessage); message WM_USER+2;
    procedure WM_UPDATE_CONTACTS(var msg:TMessage); message WM_USER+3;

    procedure CreateComponents;override;
    procedure UpdateComponents;override;
    // GroupList proc
    procedure DoGroupListChange(Sender: TObject; Node: TTreeNode);
    procedure UpdateGroupsList;
    procedure GroupStatisticView(Sender : TObject);
    procedure GroupRenameClick(Sender : TObject);
    // ContactList proc
    procedure DoContactListChange(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure UpdateContactsList;
    procedure ContactViewClick(Sender:TObject);
    procedure ContactEditClick(Sender:TObject);

  published
    property GroupList:TTreeView read fGroupList;
    property ContactList:TListView read fContactList;
  end;


implementation

{ TContactsSheet }

constructor TContactsSheet.Create(AOwner: TComponent);
begin
  inherited;
end;

procedure TContactsSheet.CreateComponents;
begin
  inherited;
  TabVisible := false;
  fGroupList := TTreeView.Create(Self);
  fGroupList.Align := alLeft;
  fGroupList.Width := 100;
  fGroupList.Parent := Self;
  fGroupList.HideSelection := false;
  fGroupList.ReadOnly := true;

  fSplitter := TSplitter.Create(Self);
  fSplitter.Left := 100;
  fSplitter.Align := alLeft;
  fSplitter.ResizeStyle := rsUpdate;
  fSplitter.Parent := Self;

  fContactList := TListView.Create(Self);
  fContactList.Align := alClient;
  fContactList.Parent := Self;
  fContactList.HideSelection := false;
  fContactList.RowSelect := true;
  fContactList.ViewStyle := vsReport;
  fContactList.ShowColumnHeaders := true;
  with fContactList.Columns.Add do
  begin
    Width := 200;
    Caption := 'Отображаемое имя';
  end;
  with fContactList.Columns.Add do
  begin
    Width := 150;
    Caption := 'Адрес';
  end;
  with fContactList.Columns.Add do
  begin
    Width := 150;
    Caption := 'Е-mail';
  end;
  with fContactList.Columns.Add do
  begin
    Width := 150;
    Caption := 'Телефоны';
  end;
  with fContactList.Columns.Add do
  begin
    Width := 150;
    Caption := 'Факсы';
  end;
  fContactList.ReadOnly := true;

  fGroupsPopup := TPopupMenu.Create(fGroupList);
  fContactsPopup := TPopupMenu.Create(fContactList);

  with fGroupsPopup.Items do
  begin
    with TMenuItem.Create(fGroupsPopup.Items) do
    begin
      Caption := 'Статистика группы';
      fGroupsPopup.Items.Add(TMenuItem(owner.Components[owner.ComponentCount-1]));
    end;
    with TMenuItem.Create(fGroupsPopup.Items) do
    begin
      Caption := '-';
      fGroupsPopup.Items.Add(TMenuItem(owner.Components[owner.ComponentCount-1]));
    end;
    with TMenuItem.Create(fGroupsPopup.Items) do
    begin
      Caption := 'Переименовать';
      fGroupsPopup.Items.Add(TMenuItem(owner.Components[owner.ComponentCount-1]));
    end;
  end;

  with fContactsPopup.Items do
  begin
    with TMenuItem.Create(fContactsPopup.Items) do
    begin
      Caption := 'Просмотр';
      OnClick := ContactViewClick;
      fContactsPopup.Items.Add(TMenuItem(owner.Components[owner.ComponentCount-1]));
    end;
    with TMenuItem.Create(fGroupsPopup.Items) do
    begin
      Caption := '-';
      fGroupsPopup.Items.Add(TMenuItem(owner.Components[owner.ComponentCount-1]));
    end;
    with TMenuItem.Create(fContactsPopup.Items) do
    begin
      Caption := 'Редактировать';
      OnClick := ContactEditClick;
      fContactsPopup.Items.Add(TMenuItem(owner.Components[owner.ComponentCount-1]));
    end;
  end;

  fGroupList.PopupMenu := fGroupsPopup;
  fContactList.PopupMenu := fContactsPopup;

end;

procedure TContactsSheet.UpdateComponents;
begin
  inherited;
  fDBContactGroups.Free;
  fDBContactsList.Free;
  fDBContactGroups := TDBContactsGroups.Create;
  fDBContactsList := TDBContactsList.Create;
  UpdateGroupsList;
  UpdateContactsList;
end;

procedure TContactsSheet.UpdateGroupsList;
var
  i: Integer;
  CG:TDBContactGroup;
  CurGroup :TId; Node, CurGroupNode : TTreeNode;
begin
  fContactList.OnChange := nil;
  fGroupList.OnChange := nil;
  CurGroupNode := nil;
  CurGroup := -1;
  if fGroupList.Items.Count > 0 then
  if fGroupList.Selected<>nil then
    CurGroup := TDBIDObject(fGroupList.Selected.Data).ID;
  fGroupList.Items.Clear;
  try
    for i := 0 to fDBContactGroups.Count-1 do
    begin
      CG := fDBContactGroups.Items[i];
      Node := fGroupList.Items.Add(nil,'');
      CG.UpdateComponent(Node);
      if CG.ID = CurGroup then CurGroupNode := Node;
    end;
  except

  end;
  if Assigned(CurGroupNode) then CurGroupNode.Selected:=true;
  fGroupList.OnChange := DoGroupListChange;
  fContactList.OnChange := DoContactListChange;
end;

procedure TContactsSheet.WM_UPDATE_ALL(var msg: TMessage);
begin
  UpdateComponents;
  msg.Msg := 0;
end;

procedure TContactsSheet.WM_UPDATE_CONTACTS(var msg: TMessage);
var i,c:nativeint;
begin
  // LParam is ID of Contact or -1 for ALL contacts update
  if msg.LParam < 0 then
  begin
    UpdateContactsList;
    exit;
  end;
  c:= fContactList.Items.Count - 1;
  for i := 0 to c do
    if TDBContact(fContactList.Items[i].Data).ID = msg.LParam then
    begin
      TDBContact(fContactList.Items[i].Data).UpdateComponent(fContactList.Items[i]);
    end;
end;

procedure TContactsSheet.WM_UPDATE_GROUPS(var msg: TMessage);
begin
  UpdateGroupsList;
  msg.Msg := 0;
end;

procedure TContactsSheet.UpdateContactsList;
var
  i: Integer;
  CT:TDBContact;
  CurCont: TId; Item, CurContItem : TListItem;
begin
  fContactList.OnChange := nil;

  if not Assigned(fGroupList.Selected) then
  begin
    fContactList.Items.Clear;
    fContactList.OnChange := DoContactListChange;
    exit;
  end;


  CurContItem := nil;
  CurCont := -1;
  if fContactList.Items.Count  >0 then
  if fContactList.Selected<>nil then
    CurCont := TDBIDObject(fContactList.Selected.Data).ID;
  fContactList.Items.Clear;
  try
    for i := 0 to fDBContactsList.Count-1 do
    begin
      CT := fDBContactsList.Items[i];
      if CT.GroupID <> TDBIDObject(fGroupList.Selected.Data).ID then continue;

      Item := fContactList.Items.Add;
      CT.UpdateComponent(Item);
      if CT.ID = CurCont then CurContItem := Item;
    end;
  except

  end;
  if Assigned(CurContItem) then CurContItem.Selected:=true;

  fContactList.OnChange := DoContactListChange;
end;

procedure TContactsSheet.DoContactListChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  if Assigned(fGroupList.Selected) then
    Application.MainForm.Caption:='Контакты -> '
                                +fGroupList.Selected.Text;
  if Assigned(fContactList.Selected) then
     Application.MainForm.Caption:=Application.MainForm.Caption
                                + ' -> ' + fContactList.Selected.Caption;
end;

procedure TContactsSheet.DoGroupListChange(Sender: TObject; Node: TTreeNode);
begin
  Application.MainForm.Caption:='Контакты -> '+fGroupList.Selected.Text;
  UpdateContactsList;
end;


// PopupMenu Clicks
procedure TContactsSheet.GroupRenameClick(Sender: TObject);
begin

end;

procedure TContactsSheet.GroupStatisticView(Sender: TObject);
begin

end;

procedure TContactsSheet.ContactEditClick(Sender: TObject);
var  CVF: TContactViewForm;
begin
  uContactViewForm.MessageDispatcher := Handle;
  if not assigned(fContactList.Selected) then
  begin
    exit;
  end;

  CVF := TContactViewForm.Create(self);
  CVF.ViewMode := vmEdit;
  CVF.Contact := fContactList.Selected.Data;
  CVF.Show;
end;

procedure TContactsSheet.ContactViewClick(Sender: TObject);
var  CVF: TContactViewForm;
begin
  uContactViewForm.MessageDispatcher := Handle;
  if not assigned(fContactList.Selected) then
  begin
    exit;
  end;

  CVF := TContactViewForm.Create(self);
  CVF.ViewMode := vmView;
  CVF.Contact := fContactList.Selected.Data;
  CVF.Show;
end;

end.
