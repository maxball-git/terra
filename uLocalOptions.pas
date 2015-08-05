unit uLocalOptions;

interface

uses uConsts, uDB,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  VCL.Dialogs, TypInfo, Vcl.Menus, Vcl.ActnList, Vcl.ComCtrls, Vcl.StdCtrls,
  Vcl.Controls,
  uLog, IniFiles;

type

  TOptions = class(TIniFile)
  private
    function GetRoot: string;
  public
    constructor Create;virtual;
    property Root:string read GetRoot;
  end;

implementation

{ TOptions }

constructor TOptions.Create;
begin
  inherited Create(Root+'Options.ini');

end;

function TOptions.GetRoot: string;
begin
  Result := ExtractFilePath(paramstr(0));
end;

end.
