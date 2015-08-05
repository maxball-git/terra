unit uAwaitingForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls;

type
  TAwaitingForm = class(TForm)
    Label1: TLabel;
    Timer1: TTimer;
    WrapPanel: TPanel;
    procedure Render(Sender: TObject);
  private
    { Private declarations }
    fBlocks:TList;
    fPos:integer;
    fBlockWidth:integer;
  public
    { Public declarations }
    constructor Create(aCaption,aText:string);virtual;
    destructor Destroy;override;
    procedure DoOnShow(Sender : TObject);
    procedure DoOnClose(Sender : TObject; Var Action : TCloseAction);
    procedure CreateBlocks;
    function NewBlock:TComponent;
    function GetBlock(index:integer):TComponent;
  end;

implementation

{$R *.dfm}

{ TAwaitingForm }

constructor TAwaitingForm.Create(aCaption, aText: string);
begin
  inherited Create(nil);
  Caption := Caption;
  Label1.Caption := aText;
  OnShow := DoOnShow;
  OnClose := DoOnClose;
  fBlocks := TList.Create;
  fPos:=0;
  fBlockWidth := 10;
  CreateBlocks;
end;

procedure TAwaitingForm.CreateBlocks;
var c:integer;
  i: Integer;
   B:TComponent;
begin
  fBlocks.Clear;
  c:= WrapPanel.Width div (fBlockWidth*2)+5;
  fBlocks.Capacity := c;
  for i := 1 to c do
  begin
    B:=NewBlock;
    fBlocks.Add(B);
  end;
end;

destructor TAwaitingForm.Destroy;
begin
  Timer1.Enabled := false;
  fBlocks.Free;
  inherited;
end;

procedure TAwaitingForm.DoOnClose(Sender : TObject; Var Action : TCloseAction);
var
  i: Integer;
begin
  Timer1.Enabled := False;
  for i := fBlocks.Count -1 downto 0 do
    TComponent(fBlocks[i]).Free;
end;

procedure TAwaitingForm.DoOnShow(Sender: TObject);
begin
  Timer1.Enabled := True;
end;

function TAwaitingForm.GetBlock(index: integer): TComponent;
begin
  if index >=0 then
    Result := fBlocks[index mod fBlocks.Count]
  else
    Result := fBlocks[fBlocks.Count-(abs(index) mod fBlocks.Count)];
end;

function TAwaitingForm.NewBlock: TComponent;
var Block:TPanel;
begin
  Block := TPanel.Create(WrapPanel);
  Block.Margins.Left:=round(fBlockWidth/2);
  Block.Margins.Right := Block.Margins.Left;
  Block.Margins.Top:=fBlockWidth;
  Block.Margins.Bottom:=fBlockWidth;
  Block.AlignWithMargins:=true;
  Block.Width := fBlockWidth;

  Block.BevelInner:=bvNone;
  Block.BevelOuter:=bvNone;
  Block.BevelKind:=bkFlat;
  Block.ParentBackground := false;
  Block.Align:=alLeft;
  Block.Left:=10000;
  Block.Color := clWhite;
  Block.Parent := WrapPanel;
  Result := Block;
end;

procedure TAwaitingForm.Render(Sender: TObject);
var Block:TPanel;
begin
  Timer1.Enabled:=false;
  Block := TPanel(GetBlock(fPos-5)); Block.Color := clWhite;
  Block := TPanel(GetBlock(fPos-4)); Block.Color := rgb(200,255,200);
  Block := TPanel(GetBlock(fPos-3)); Block.Color := rgb(150,255,150);
  Block := TPanel(GetBlock(fPos-2)); Block.Color := rgb(100,255,100);
  Block := TPanel(GetBlock(fPos-1)); Block.Color := rgb(50,255,50);
  Block := TPanel(GetBlock(  fPos)); Block.Color := rgb(0,255,0);
  Inc(fPos);
  Timer1.Enabled:=true;
end;

end.
