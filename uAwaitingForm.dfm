object AwaitingForm: TAwaitingForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Please wait'
  ClientHeight = 69
  ClientWidth = 380
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    AlignWithMargins = True
    Left = 10
    Top = 10
    Width = 360
    Height = 13
    Margins.Left = 10
    Margins.Top = 10
    Margins.Right = 10
    Margins.Bottom = 10
    Align = alTop
    Alignment = taCenter
    Caption = 'Label1'
    ExplicitLeft = 8
    ExplicitTop = 11
    ExplicitWidth = 31
  end
  object WrapPanel: TPanel
    AlignWithMargins = True
    Left = 10
    Top = 36
    Width = 360
    Height = 30
    Margins.Left = 10
    Margins.Right = 10
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 50
    OnTimer = Render
    Left = 328
  end
end
