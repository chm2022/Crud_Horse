program SHAppDoces;

uses
  System.StartUpCopy,
  FMX.Forms,
  UnitPrincipal in 'UnitPrincipal.pas' {FrmPrincipal},
  Controllers.Usuario in 'Controller\Controllers.Usuario.pas',
  DataModule.Global in 'DataModule\DataModule.Global.pas' {DmGlobal: TDataModule},
  uMD5 in 'Units\uMD5.pas',
  Controllers.Auth in 'Controller\Controllers.Auth.pas',
  Controllers.Cliente in 'Controller\Controllers.Cliente.pas',
  Controllers.Produto in 'Controller\Controllers.Produto.pas';

{$R *.res}

begin
  //ReportMemoryLeaksOnShutdown := true;
  Application.Initialize;
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.Run;
end.
