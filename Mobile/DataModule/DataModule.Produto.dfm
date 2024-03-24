object DmProduto: TDmProduto
  Height = 270
  Width = 298
  object qryConsProduto: TFDQuery
    Left = 64
    Top = 24
  end
  object qryProduto: TFDQuery
    Left = 192
    Top = 24
  end
  object TabProduto: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 72
    Top = 120
  end
end
