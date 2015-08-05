unit uProducts;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Menus, Vcl.ComCtrls,
  Vcl.AppEvnts, Vcl.CategoryButtons, Vcl.ButtonGroup, System.Actions,
  Vcl.ActnList, Vcl.StdCtrls,
  uLog, uConsts, uDB, uLogin, uDBCustomObjects, uAppTabSheet;

type

  TProductSheet = class(TAppTabSheet)
  private
    fProductList: TListView;
  public
    procedure CreateComponents;override;
    procedure UpdateComponents;override;
  published
    property ProductList:TListView read fProductList;
  end;

implementation

{ TProductSheet }

procedure TProductSheet.CreateComponents;
begin
  inherited;
  fProductList := TListView.Create(Self);
  fProductList.Align := alClient;
  fProductList.Parent := Self;
end;

procedure TProductSheet.UpdateComponents;
begin
  inherited;

end;

end.
