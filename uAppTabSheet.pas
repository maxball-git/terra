unit uAppTabSheet;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Menus, Vcl.ComCtrls,
  Vcl.AppEvnts, Vcl.CategoryButtons, Vcl.ButtonGroup, System.Actions,
  Vcl.ActnList, Vcl.StdCtrls,
  uLog, uConsts, uDB, uLogin, uDBCustomObjects;

type

  TAppTabSheet = class(TTabSheet)
  public
    constructor Create(AOwner: TComponent); override;
    procedure DoTabEnter(Sender:TObject); virtual;

    procedure CreateComponents;virtual;
    procedure UpdateComponents;virtual;
  published
  end;

implementation

{ TAppTabSheet }

constructor TAppTabSheet.Create(AOwner: TComponent);
begin
  inherited;
  TabVisible := false;
  CreateComponents;
  OnShow  := DoTabEnter;
end;

procedure TAppTabSheet.CreateComponents;
begin

end;

procedure TAppTabSheet.DoTabEnter(Sender: TObject);
begin
  UpdateComponents;
end;

procedure TAppTabSheet.UpdateComponents;
begin

end;

end.
