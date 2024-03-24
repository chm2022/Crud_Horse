object DmCliente: TDmCliente
  Height = 268
  Width = 398
  object qryConsCliente: TFDQuery
    Left = 104
    Top = 56
  end
  object qryCliente: TFDQuery
    Left = 248
    Top = 56
  end
  object TabCliente: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 104
    Top = 160
  end
end
