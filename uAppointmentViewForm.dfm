object AppointmentViewForm: TAppointmentViewForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'AppointmentViewForm'
  ClientHeight = 313
  ClientWidth = 519
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 249
    Top = 19
    Width = 4
    Height = 215
    ResizeStyle = rsUpdate
    ExplicitTop = 0
    ExplicitHeight = 224
  end
  object lblTitle: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 513
    Height = 13
    Align = alTop
    Caption = 'lblTitle'
    WordWrap = True
    ExplicitWidth = 30
  end
  object Panel1: TPanel
    Left = 0
    Top = 234
    Width = 519
    Height = 48
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      519
      48)
    object ledDescription: TLabeledEdit
      Left = 8
      Top = 20
      Width = 503
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      EditLabel.Width = 53
      EditLabel.Height = 13
      EditLabel.Caption = #1054#1087#1080#1089#1072#1085#1080#1077':'
      TabOrder = 0
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 19
    Width = 249
    Height = 215
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitTop = 0
    ExplicitHeight = 234
    object Label1: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 243
      Height = 13
      Align = alTop
      Caption = #1057#1087#1088#1072#1074#1086#1095#1085#1080#1082' '#1076#1086#1083#1078#1085#1086#1089#1090#1077#1081
      ExplicitWidth = 126
    end
    object lstAppointments: TListView
      AlignWithMargins = True
      Left = 3
      Top = 22
      Width = 246
      Height = 190
      Margins.Right = 0
      Align = alClient
      Columns = <
        item
          Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077
          Width = 150
        end
        item
          AutoSize = True
          Caption = #1054#1087#1080#1089#1072#1085#1080#1077
        end>
      HideSelection = False
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      ExplicitHeight = 209
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 282
    Width = 519
    Height = 31
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    object btnAction: TButton
      AlignWithMargins = True
      Left = 441
      Top = 3
      Width = 75
      Height = 25
      Align = alRight
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      Default = True
      TabOrder = 0
      OnClick = btnActionClick
    end
    object btnCancel: TButton
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 75
      Height = 25
      Align = alLeft
      Cancel = True
      Caption = #1054#1090#1084#1077#1085#1080#1090#1100
      ModalResult = 2
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
  object Panel4: TPanel
    Left = 253
    Top = 19
    Width = 266
    Height = 215
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 0
    ExplicitHeight = 234
    object Label2: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 260
      Height = 13
      Align = alTop
      Caption = #1056#1072#1073#1086#1090#1086#1076#1072#1090#1077#1083#1080' ('#1050#1086#1085#1090#1072#1082#1090#1099')'
      ExplicitWidth = 135
    end
    object lstEmployers: TListView
      AlignWithMargins = True
      Left = 0
      Top = 22
      Width = 263
      Height = 190
      Margins.Left = 0
      Align = alClient
      Columns = <
        item
          AutoSize = True
          Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077
        end>
      HideSelection = False
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      ExplicitHeight = 209
    end
  end
end
