unit UnitLogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl,
  FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Edit;

type
  TFrmLogin = class(TForm)
    TabControl: TTabControl;
    TabLogin: TTabItem;
    TabCriarConta: TTabItem;
    rectFundoLogin: TRectangle;
    imgLogin: TImage;
    Label7: TLabel;
    lytCamposLogin: TLayout;
    lblCriar: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edtEmail: TEdit;
    edtSenha: TEdit;
    btnLogin: TSpeedButton;
    rectFundoConta: TRectangle;
    imgConta: TImage;
    Label4: TLabel;
    lytCamposConta: TLayout;
    Label5: TLabel;
    Label6: TLabel;
    edtContaNome: TEdit;
    edtContaSenha: TEdit;
    btnCriarConta: TSpeedButton;
    lblLogin: TLabel;
    edtContaEmail: TEdit;
    Label9: TLabel;
    StyleBook1: TStyleBook;
    procedure lblCriarClick(Sender: TObject);
    procedure lblLoginClick(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnCriarContaClick(Sender: TObject);
    procedure FormVirtualKeyboardShown(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormVirtualKeyboardHidden(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
  private
    procedure ThreadLoginTerminate(Sender: TObject);
    procedure OpenFormPrincipal;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmLogin: TFrmLogin;

implementation

{$R *.fmx}

uses UnitPrincipal, DataModule.Usuario, DataModule.Global;

procedure TFrmLogin.OpenFormPrincipal;
begin
    if NOT Assigned(FrmPrincipal) then
        Application.CreateForm(TFrmPrincipal, FrmPrincipal);

    Application.MainForm := FrmPrincipal;
    FrmPrincipal.Show;
    FrmLogin.Close;
end;

procedure TFrmLogin.ThreadLoginTerminate(Sender: TObject);
begin
    TLoading.Hide;

    if Sender is TThread then
        if Assigned(TThread(Sender).FatalException) then
        begin
            fancy.Show(TIconDialog.Error, '', Exception(TThread(sender).FatalException).Message, 'OK');
            exit;
        end;

    OpenFormPrincipal;
end;

procedure TFrmLogin.btnCriarContaClick(Sender: TObject);
var
    t: TThread;
begin
    TLoading.Show(FrmLogin, '');

    t := TThread.CreateAnonymousThread(procedure
    begin
        DmUsuario.NovaContaWeb(edtContaNome.Text, edtContaEmail.Text, edtContaSenha.Text);

        with DmUsuario.TabUsuario do
        begin
            DmUsuario.Logout;
            DmUsuario.ExcluirUsuario;

            DmUsuario.InserirUsuario(FieldByName('cod_usuario').AsInteger,
                                     edtContaNome.text,
                                     edtContaEmail.text,
                                     edtContaSenha.Text,
                                     FieldByName('token').AsString);
        end;
    end);

    t.OnTerminate := ThreadLoginTerminate;
    t.Start;
end;

procedure TFrmLogin.btnLoginClick(Sender: TObject);
var
    t: TThread;
begin
    TLoading.Show(FrmLogin, '');

    t := TThread.CreateAnonymousThread(procedure
    begin
        DmUsuario.LoginWeb(edtEmail.Text, edtSenha.Text);

        with DmUsuario.TabUsuario do
        begin
            DmUsuario.Logout;
            DmUsuario.ExcluirUsuario;

            DmUsuario.InserirUsuario(FieldByName('cod_usuario').AsInteger,
                                     FieldByName('nome').AsString,
                                     FieldByName('email').AsString,
                                     edtSenha.Text,
                                     FieldByName('token').AsString);
        end;
    end);

    t.OnTerminate := ThreadLoginTerminate;
    t.Start;
end;

procedure TFrmLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := TCloseAction.caFree;
    FrmLogin := nil;
end;

procedure TFrmLogin.FormCreate(Sender: TObject);
begin
    fancy := TFancyDialog.Create(FrmLogin);
end;

procedure TFrmLogin.FormDestroy(Sender: TObject);
begin
    fancy.DisposeOf;
end;

procedure TFrmLogin.FormVirtualKeyboardHidden(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
begin
    imgLogin.Height := 85;
    rectFundoLogin.Height := 180;
    lytCamposLogin.Margins.Bottom := 0;

    imgConta.Height := 85;
    rectFundoConta.Height := 180;
    lytCamposConta.Margins.Bottom := 0;
end;

procedure TFrmLogin.FormVirtualKeyboardShown(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
begin
    imgLogin.Height := 40;
    rectFundoLogin.Height := 100;
    lytCamposLogin.Margins.Bottom := 140;

    imgConta.Height := 30;
    rectFundoConta.Height := 80;
    lytCamposConta.Margins.Bottom := 160;
end;

procedure TFrmLogin.lblCriarClick(Sender: TObject);
begin
    TabControl.GotoVisibleTab(1);
end;

procedure TFrmLogin.lblLoginClick(Sender: TObject);
begin
    TabControl.GotoVisibleTab(0);
end;

end.
