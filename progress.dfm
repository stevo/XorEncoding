object GaugeForm: TGaugeForm
  Left = 263
  Top = 211
  BorderIcons = [biMinimize, biMaximize]
  BorderStyle = bsDialog
  Caption = 'Encryption/Decryption in Progress'
  ClientHeight = 113
  ClientWidth = 319
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel2: TBevel
    Left = 8
    Top = 8
    Width = 305
    Height = 97
  end
  object Gauge1: TGauge
    Left = 16
    Top = 16
    Width = 289
    Height = 81
    BackColor = clInfoBk
    Color = clBtnText
    ForeColor = clBackground
    Kind = gkVerticalBar
    ParentColor = False
    Progress = 0
  end
end
