unit UnitInicial;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Layouts;

type
  TFrmInicial = class(TForm)
    TabControl: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    TabItem3: TTabItem;
    TabItem4: TTabItem;
    Layout1: TLayout;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Layout2: TLayout;
    btnProximo1: TSpeedButton;
    StyleBook1: TStyleBook;
    Layout3: TLayout;
    Image2: TImage;
    Label3: TLabel;
    Label4: TLabel;
    Layout4: TLayout;
    btnProximo2: TSpeedButton;
    btnVoltar2: TSpeedButton;
    Layout5: TLayout;
    Image3: TImage;
    Label5: TLabel;
    Label6: TLabel;
    Layout6: TLayout;
    btnProximo3: TSpeedButton;
    btnVoltar3: TSpeedButton;
    Layout7: TLayout;
    Image4: TImage;
    Label7: TLabel;
    Layout8: TLayout;
    btnAcessar: TSpeedButton;
    btnCriar: TSpeedButton;
    timerLoad: TTimer;
    procedure btnProximo1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnAcessarClick(Sender: TObject);
    procedure btnCriarClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    procedure AbrirAba(index: integer);
  public

  end;

var
  FrmInicial: TFrmInicial;

implementation

{$R *.fmx}

uses UnitLogin, DataModule.Usuario, UnitPrincipal;

procedure TFrmInicial.AbrirAba(index: integer);
begin
  TabControl.GotoVisibleTab(index);
end;

procedure TFrmInicial.btnAcessarClick(Sender: TObject);
begin
    try
        // Desativar onboarding...
        DmUsuario.DesativarOnboarding;
    except on ex:exception do
        fancy.Show(TIconDialog.Error, 'Erro', ex.Message, 'OK');
    end;

    if NOT Assigned(FrmLogin) then
        Application.CreateForm(TFrmLogin, FrmLogin);

    FrmLogin.TabControl.ActiveTab := FrmLogin.TabLogin;

    Application.MainForm := FrmLogin;
    FrmLogin.Show;
    FrmInicial.Close;
end;

procedure TFrmInicial.btnCriarClick(Sender: TObject);
begin
    try
        // Desativar onboarding...
        DmUsuario.DesativarOnboarding;
    except on ex:exception do
        fancy.Show(TIconDialog.Error, 'Erro', ex.Message, 'OK');
    end;

    if NOT Assigned(FrmLogin) then
        Application.CreateForm(TFrmLogin, FrmLogin);

    FrmLogin.TabControl.ActiveTab := FrmLogin.TabCriarConta;

    Application.MainForm := FrmLogin;
    FrmLogin.Show;
    FrmInicial.Close;
end;

procedure TFrmInicial.btnProximo1Click(Sender: TObject);
begin
     AbrirAba(TSpeedButton(Sender).Tag);
end;

procedure TFrmInicial.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := TCloseAction.caFree;
    FrmInicial := nil;
end;

procedure TFrmInicial.FormCreate(Sender: TObject);
begin
    TabControl.ActiveTab := TabItem1;
    fancy := TFancyDialog.Create(FrmInicial);
end;

procedure TFrmInicial.FormDestroy(Sender: TObject);
begin
    fancy.DisposeOf;
end;

end.
