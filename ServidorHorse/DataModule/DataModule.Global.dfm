object DmGlobal: TDmGlobal
  OnCreate = DataModuleCreate
  Height = 172
  Width = 311
  object Conn: TFDConnection
    Params.Strings = (
      'User_Name=sysdba'
      'Password=masterkey'
      'DriverID=FB')
    LoginPrompt = False
    BeforeConnect = ConnBeforeConnect
    Left = 56
    Top = 8
  end
  object FDPhysFBDriverLink: TFDPhysFBDriverLink
    Left = 56
    Top = 88
  end
end
