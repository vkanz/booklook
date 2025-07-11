object Form14: TForm14
  Left = 0
  Top = 0
  Caption = 'Form14'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object Edit1: TEdit
    Left = 48
    Top = 24
    Width = 497
    Height = 23
    TabOrder = 0
    Text = '..\..\Test\'
  end
  object Button1: TButton
    Left = 470
    Top = 64
    Width = 75
    Height = 25
    Caption = 'Read'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 0
    Top = 184
    Width = 624
    Height = 257
    Align = alBottom
    ScrollBars = ssBoth
    TabOrder = 2
  end
  object Edit_Database: TEdit
    Left = 48
    Top = 112
    Width = 497
    Height = 23
    TabOrder = 3
    Text = 'Database'
  end
end
