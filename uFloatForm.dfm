object FloatForm: TFloatForm
  Left = 0
  Top = 0
  AlphaBlendValue = 150
  BorderStyle = bsNone
  Caption = 'FloatForm'
  ClientHeight = 66
  ClientWidth = 237
  Color = clWindow
  Constraints.MinWidth = 150
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  PopupMode = pmAuto
  Position = poMainFormCenter
  Scaled = False
  ScreenSnap = True
  PixelsPerInch = 96
  TextHeight = 13
  object CoolBar1: TCoolBar
    Left = 0
    Top = 0
    Width = 237
    Height = 42
    AutoSize = True
    Bands = <
      item
        Control = ToolBar1
        ImageIndex = -1
        MinHeight = 38
        Width = 231
      end>
    Constraints.MaxHeight = 42
    Constraints.MinHeight = 42
    ExplicitWidth = 231
    object ToolBar1: TToolBar
      Left = 11
      Top = 0
      Width = 222
      Height = 38
      AutoSize = True
      ButtonHeight = 38
      ButtonWidth = 39
      Caption = 'ToolBar1'
      TabOrder = 0
      object ToolButton1: TToolButton
        Left = 0
        Top = 0
        Caption = 'ToolButton1'
        ImageIndex = 0
      end
    end
  end
end
