unit uAppForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uLocalOptions;

type
  TAppForm = class(TForm)
  private
    { Private declarations }
  public
    { Public declarations }
    constructor Create(Aowner :TComponent);override;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

{ TAppForm }

constructor TAppForm.Create(Aowner: TComponent);
begin
  inherited;
  with TOptions.Create do
  begin
    Left := ReadInteger(Self.ClassName,'Left',Left);
    Top := ReadInteger(Self.ClassName,'Top',Top);
    Width := ReadInteger(Self.ClassName,'Width',Width);
    Height := ReadInteger(Self.ClassName,'Height',Height);
    free;
  end;
  if Left<0 then Left := 0;
  if Top<0 then Top := 0;
  if Width < 400 then Width := 400;
  if Height < 400 then Height := 400;
  if (Width+left) > Screen.Width then left := Screen.Width - Width;
  if (Height+Top) > Screen.Height then Top := Screen.Height - Height;
end;

destructor TAppForm.Destroy;
begin
  with TOptions.Create do
  begin
    WriteInteger(Self.ClassName,'Left',Left);
    WriteInteger(Self.ClassName,'Top',Top);
    WriteInteger(Self.ClassName,'Width',Width);
    WriteInteger(Self.ClassName,'Height',Height);
    free;
  end;
  inherited;
end;

end.
