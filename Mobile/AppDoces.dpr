program AppDoces;

uses
  System.StartUpCopy,
  FMX.Forms,
  UnitInicial in 'UnitInicial.pas' {FrmInicial},
  UnitLogin in 'UnitLogin.pas' {FrmLogin},
  UnitPrincipal in 'UnitPrincipal.pas' {FrmPrincipal},
  DataModule.Cliente in 'DataModule\DataModule.Cliente.pas' {DmCliente: TDataModule},
  DataModule.Produto in 'DataModule\DataModule.Produto.pas' {DmProduto: TDataModule},
  UnitProdutoCad in 'UnitProdutoCad.pas' {FrmProdutoCad},
  UnitClienteCad in 'UnitClienteCad.pas' {FrmClienteCad},
  DataModule.Usuario in 'DataModule\DataModule.Usuario.pas' {DmUsuario: TDataModule},
  UnitCliente in 'UnitCliente.pas' {FrmCliente},
  Frame.Produto in 'Frames\Frame.Produto.pas' {FrameProduto: TFrame},
  Frame.Menu in 'Frames\Frame.Menu.pas' {FrameMenu: TFrame},
  UnitProduto in 'UnitProduto.pas' {FrmProduto};

{$R *.res}

begin
  //ReportMemoryLeaksOnShutdown := true;
  Application.Initialize;
  Application.CreateForm(TFrmInicial, FrmInicial);
  Application.Run;
end.
