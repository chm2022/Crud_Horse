object DmUsuario: TDmUsuario
  Height = 214
  Width = 257
  object qryUsuario: TFDQuery
    Left = 160
    Top = 24
  end
  object qryConsUsuario: TFDQuery
    Left = 56
    Top = 24
  end
  object TabUsuario: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 104
    Top = 104
  end
end
