object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MainForm'
  ClientHeight = 432
  ClientWidth = 616
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  PixelsPerInch = 96
  TextHeight = 16
  object Splitter1: TSplitter
    Left = 163
    Top = 0
    Width = 4
    Height = 432
    ResizeStyle = rsUpdate
    ExplicitLeft = 514
    ExplicitTop = 48
    ExplicitHeight = 446
  end
  object PageControl1: TPageControl
    Left = 167
    Top = 0
    Width = 449
    Height = 432
    Align = alClient
    TabOrder = 0
  end
  object CategoryButtons1: TCategoryButtons
    Left = 0
    Top = 0
    Width = 163
    Height = 432
    Align = alLeft
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    ButtonFlow = cbfVertical
    ButtonHeight = 30
    ButtonOptions = [boFullSize, boShowCaptions, boBoldCaptions, boCaptionOnlyBorder]
    Categories = <
      item
        Caption = #1054#1073#1097#1080#1077
        Color = 16755370
        Collapsed = False
        Items = <
          item
            Action = actNews
          end
          item
            Action = actLogin
          end>
      end
      item
        Caption = #1054#1089#1085#1086#1074#1085#1099#1077
        Color = 11197951
        Collapsed = False
        Items = <
          item
            Action = actContacts
          end
          item
            Action = actProducts
          end>
      end
      item
        Caption = #1040#1076#1084#1080#1085#1080#1089#1090#1088#1080#1088#1086#1074#1072#1085#1080#1077
        Color = 11315967
        Collapsed = False
        Items = <
          item
            Action = actUsers
          end
          item
            Action = actAccess
          end
          item
          end>
      end>
    Color = clGradientInactiveCaption
    DoubleBuffered = True
    HotButtonColor = clHotLight
    ParentDoubleBuffered = False
    RegularButtonColor = clNone
    SelectedButtonColor = clHotLight
    TabOrder = 1
  end
  object ApplicationEvents1: TApplicationEvents
    OnActionExecute = ApplicationEvents1ActionExecute
    OnActivate = ApplicationEvents1Activate
    OnDeactivate = ApplicationEvents1Deactivate
    OnException = ApplicationEvents1Exception
    OnHelp = ApplicationEvents1Help
    OnHint = ApplicationEvents1Hint
    OnMessage = ApplicationEvents1Message
    OnMinimize = ApplicationEvents1Minimize
    OnRestore = ApplicationEvents1Restore
    OnShortCut = ApplicationEvents1ShortCut
    OnSettingChange = ApplicationEvents1SettingChange
    Left = 489
    Top = 142
  end
  object ActionList: TActionList
    Left = 83
    Top = 310
    object actNews: TAction
      Category = #1054#1073#1097#1080#1077
      Caption = #1053#1086#1074#1086#1089#1090#1080
    end
    object actLogin: TAction
      Category = #1054#1073#1097#1080#1077
      Caption = #1042#1093#1086#1076
      OnExecute = actLoginExecute
    end
    object actContacts: TAction
      Category = #1054#1089#1085#1086#1074#1085#1099#1077
      Caption = #1050#1086#1085#1090#1072#1082#1090#1099
      OnExecute = actContactsExecute
    end
    object actProducts: TAction
      Category = #1054#1089#1085#1086#1074#1085#1099#1077
      Caption = #1055#1088#1086#1076#1091#1082#1094#1080#1103
      OnExecute = actProductsExecute
    end
    object actUsers: TAction
      Category = #1040#1076#1084#1080#1085#1080#1089#1090#1088#1080#1088#1086#1074#1072#1085#1080#1077
      Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1080
    end
    object actAccess: TAction
      Category = #1040#1076#1084#1080#1085#1080#1089#1090#1088#1080#1088#1086#1074#1072#1085#1080#1077
      Caption = #1044#1086#1089#1090#1091#1087
    end
    object actChangeRole: TAction
      Category = #1040#1076#1084#1080#1085#1080#1089#1090#1088#1080#1088#1086#1074#1072#1085#1080#1077
      Caption = #1042#1088#1077#1084#1077#1085#1085#1086' '#1057#1084#1077#1085#1080#1090#1100' '#1056#1086#1083#1100
      ShortCut = 57426
      OnExecute = actChangeRoleExecute
    end
  end
end
