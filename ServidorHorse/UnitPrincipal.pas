unit UnitPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects;

type
  TFrmPrincipal = class(TForm)
    Label1: TLabel;
    memo: TMemo;
    Label2: TLabel;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.fmx}

uses Horse,
     Horse.Jhonson,
     Horse.CORS,
     Horse.Upload,
     Horse.OctetStream,
     Controllers.Usuario,
     Controllers.Cliente,
     Controllers.Produto;


procedure TFrmPrincipal.FormShow(Sender: TObject);
begin
    THorse.Use(Jhonson());
    THorse.Use(CORS);
    THorse.Use(OctetStream);
    THorse.Use(Upload);

    // Registrar as rotas...
    Controllers.Usuario.RegistrarRotas;
    Controllers.Cliente.RegistrarRotas;
    Controllers.Produto.RegistrarRotas;
    THorse.Listen(9000);

    memo.Lines.Add('Servidor executando na porta: ' + THorse.Port.ToString);
end;

end.
