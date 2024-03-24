unit UnitClienteCad;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Layouts, FMX.ListBox,
  System.Sensors, System.Sensors.Components,
  FMX.Ani, FMX.Effects, FMX.Filter.Effects, FMX.Edit,
  FMX.ComboEdit, FMX.DateTimeCtrls;

type
  TExecuteOnClose = procedure of Object;

  TFrmClienteCad = class(TForm)
    rectToolbar: TRectangle;
    lblTitulo: TLabel;
    btnVoltar: TSpeedButton;
    Image4: TImage;
    LocationSensor: TLocationSensor;
    Rectangle2: TRectangle;
    lblFone: TLabel;
    Image3: TImage;
    Rectangle3: TRectangle;
    Image5: TImage;
    lblEmail: TLabel;
    Rectangle4: TRectangle;
    Rectangle5: TRectangle;
    Rectangle6: TRectangle;
    Rectangle7: TRectangle;
    Rectangle8: TRectangle;
    Rectangle9: TRectangle;
    Image6: TImage;
    lblEndereco: TLabel;
    Image7: TImage;
    lblNumero: TLabel;
    Image8: TImage;
    lblComplemento: TLabel;
    Image9: TImage;
    lblBairro: TLabel;
    Image10: TImage;
    lblCidade: TLabel;
    Image11: TImage;
    lblUF: TLabel;
    Rectangle10: TRectangle;
    Rectangle11: TRectangle;
    Image12: TImage;
    lblCEP: TLabel;
    Image13: TImage;
    lblLimite: TLabel;
    Rectangle12: TRectangle;
    Image14: TImage;
    lblCNPJ: TLabel;
    btnLocalizacao: TSpeedButton;
    Image16: TImage;
    Label2: TLabel;
    Label4: TLabel;
    Label10: TLabel;
    Label8: TLabel;
    Label6: TLabel;
    Label12: TLabel;
    Label14: TLabel;
    Label16: TLabel;
    Label18: TLabel;
    Label20: TLabel;
    Label22: TLabel;
    rectTotal: TRectangle;
    lyt_inserir_item: TLayout;
    Layout3: TLayout;
    Circle1: TCircle;
    btn_salvar: TCircle;
    Rectangle13: TRectangle;
    Image18: TImage;
    Label3: TLabel;
    Image1: TImage;
    Label1: TLabel;
    Layout2: TLayout;
    LblNomeUsuario: TLabel;
    Rectangle1: TRectangle;
    lblNome: TLabel;
    Image2: TImage;
    procedure btnVoltarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListBox1ItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure btnLocalizacaoClick(Sender: TObject);
    procedure LocationSensorLocationChanged(Sender: TObject; const OldLocation,
      NewLocation: TLocationCoord2D);
    procedure Image14Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure Image5Click(Sender: TObject);
    procedure Image6Click(Sender: TObject);
    procedure Image7Click(Sender: TObject);
    procedure Image8Click(Sender: TObject);
    procedure Image9Click(Sender: TObject);
    procedure Image10Click(Sender: TObject);
    procedure Image11Click(Sender: TObject);
    procedure Image12Click(Sender: TObject);
    procedure Image13Click(Sender: TObject);
    procedure btn_salvarClick(Sender: TObject);
  private
    latitude, longitude: double;
    FCod_cliente: integer;
    FModo: string;
    FExecuteOnClose: TExecuteOnClose;
    procedure ErroLocalizacao(Sender: TObject);
    procedure ObterLocalizacao(Sender: TObject);

    { Private declarations }
  public
    property Modo: string read FModo write FModo;
    property Cod_Cliente: integer read FCod_cliente write FCod_cliente;
    property ExecuteOnClose: TExecuteOnClose read FExecuteOnClose write FExecuteOnClose;
  end;

var
  FrmClienteCad: TFrmClienteCad;

implementation

{$R *.fmx}

uses UnitPrincipal, DataModule.Cliente, UnitEdicao;

procedure TFrmClienteCad.ObterLocalizacao(Sender: TObject);
begin
    LocationSensor.Active := true;
end;

procedure TFrmClienteCad.ErroLocalizacao(Sender: TObject);
begin
    fancy.Show(TIconDialog.Error, 'Permissão', 'Você não possui acesso ao GPS do aparelho.', 'OK');
end;

procedure TFrmClienteCad.SolicitarAcessoGPS(Sender: TObject);
begin
    permissao.Location(ObterLocalizacao, ErroLocalizacao);
end;

procedure TFrmClienteCad.btnLocalizacaoClick(Sender: TObject);
begin

  fancy.Show(TIconDialog.Question, 'Acesso ao GPS',
             'Para sugerir o endereço do cliente, o app precisa acessar o GPS do aparelho',
             'Continuar', SolicitarAcessoGPS,
             'Cancelar');
end;

procedure TFrmClienteCad.btnVoltarClick(Sender: TObject);
begin
    close;
end;

procedure TFrmClienteCad.btn_salvarClick(Sender: TObject);
begin

   if lblCNPJ.Text = '' then
    begin
        fancy.Show(TIconDialog.Warning, 'Aviso', 'Informe o CNPJ/CPF do cliente', 'OK');
        exit;
    end;
    if lblNome.Text = '' then
    begin
        fancy.Show(TIconDialog.Warning, 'Aviso', 'Informe o nome do cliente', 'OK');
        exit;
    end;
    if lblCidade.Text = '' then
    begin
        fancy.Show(TIconDialog.Warning, 'Aviso', 'Informe a cidade do cliente', 'OK');
        exit;
    end;
    if lblUF.Text = '' then
    begin
        fancy.Show(TIconDialog.Warning, 'Aviso', 'Informe a UF do cliente', 'OK');
        exit;
    end;

    try
        if Modo = 'I' then
            DmCliente.InserirCliente(lblCNPJ.Text, lblNome.Text, lblFone.Text, lblEmail.Text,
                                     lblEndereco.Text, lblNumero.Text, lblComplemento.Text,
                                     lblBairro.Text, lblCidade.Text, lblUF.Text, lblCEP.Text,
                                     StringToFloat(lblLImite.Text), latitude, longitude, 'S', 0)
        else
            DmCliente.EditarCliente(Cod_Cliente, lblCNPJ.Text, lblNome.Text, lblFone.Text, lblEmail.Text,
                                    lblEndereco.Text, lblNumero.Text, lblComplemento.Text,
                                    lblBairro.Text, lblCidade.Text, lblUF.Text, lblCEP.Text, 'S',
                                    StringToFloat(lblLImite.Text), latitude, longitude);

        if Assigned(ExecuteOnClose) then
            ExecuteOnClose;

        close;

    except on ex:exception do
        fancy.Show(TIconDialog.Error, 'Erro', 'Erro ao salvar dados do cliente: ' + ex.Message, 'OK');
    end;


end;

procedure TFrmClienteCad.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := TCloseAction.caFree;
    FrmClienteCad := nil;
end;

{$IFDEF MSWINDOWS}
procedure TFrmClienteCad.onComboClick(Sender: TObject);
begin
    combo.HideMenu;
    lblUF.Text := combo.CodItem;
    //lblUF.Text := combo.DescrItem;
end;
{$ELSE}
procedure TFrmClienteCad.onComboClick(Sender: TObject; const Point: TPointF);
begin
    combo.HideMenu;
    lblUF.Text := combo.CodItem;
end;
{$ENDIF}

procedure TFrmClienteCad.FormCreate(Sender: TObject);
begin
    fancy := TFancyDialog.Create(FrmClienteCad);
    permissao := T99Permissions.Create;

    // Listagem dos estados...
    combo := TCustomCombo.Create(FrmClienteCad);
    combo.TitleMenuText := 'Estado do Cliente';
    combo.BackgroundColor := $FFF2F2F8;
    combo.ItemBackgroundColor := $FFFFFFFF;

    combo.AddItem('AC', 'Acre');
    combo.AddItem('AL', 'Alagoas');
    combo.AddItem('AP', 'Amapá');
    combo.AddItem('AM', 'Amazonas');

    combo.OnClick := onComboClick;
end;

procedure TFrmClienteCad.FormDestroy(Sender: TObject);
begin
    fancy.DisposeOf;
    permissao.DisposeOf;
    combo.DisposeOf;

    if Assigned(GeoCoder) then
        GeoCoder.DisposeOf;
end;

procedure TFrmClienteCad.FormShow(Sender: TObject);
begin
    try
        //btnExcluir.Visible := Modo = 'A';
        latitude := 0;
        longitude := 0;

        if Modo = 'A' then
        begin
            DmCliente.ListarClienteId(Cod_Cliente, 0);

            lblCNPJ.Text := DmCliente.qryCliente.FieldByName('cnpj_cpf').AsString;
            lblNome.Text := DmCliente.qryCliente.FieldByName('nome').AsString;
            lblFone.Text := DmCliente.qryCliente.FieldByName('fone').AsString;
            lblEmail.Text := DmCliente.qryCliente.FieldByName('email').AsString;
            lblEndereco.Text := DmCliente.qryCliente.FieldByName('endereco').AsString;
            lblNumero.Text := DmCliente.qryCliente.FieldByName('numero').AsString;
            lblComplemento.Text := DmCliente.qryCliente.FieldByName('complemento').AsString;
            lblBairro.Text := DmCliente.qryCliente.FieldByName('bairro').AsString;
            lblCidade.Text := DmCliente.qryCliente.FieldByName('cidade').AsString;
            lblUF.Text := DmCliente.qryCliente.FieldByName('uf').AsString;
            lblCEP.Text := DmCliente.qryCliente.FieldByName('cep').AsString;
            lblLimite.Text := FormatFloat('#,##0.00', DmCliente.qryCliente.FieldByName('limite_disponivel').AsFloat);
            latitude := DmCliente.qryCliente.FieldByName('latitude').AsFloat;
            longitude := DmCliente.qryCliente.FieldByName('longitude').AsFloat;
            lblTitulo.Text := 'Editar Cliente';
        end;
    except on ex:exception do
        fancy.Show(TIconDialog.Error, 'Erro', 'Erro ao carregar dados do cliente: ' + ex.Message, 'OK');
    end;
end;

procedure TFrmClienteCad.Image10Click(Sender: TObject);
begin

  FrmEdicao.Editar(lblCidade, TTipoCampo.Edit, 'Cidade do Cliente',
                   'Informe a cidade', lblCidade.Text, true, 50)

end;

procedure TFrmClienteCad.Image11Click(Sender: TObject);
begin

   combo.ShowMenu

end;

procedure TFrmClienteCad.Image12Click(Sender: TObject);
begin

   FrmEdicao.Editar(lblCEP, TTipoCampo.Edit, 'CEP do Cliente',
                    'Informe o CEP', lblCEP.Text, false, 10, FormatarCampos)

end;

procedure TFrmClienteCad.Image13Click(Sender: TObject);
begin

   FrmEdicao.Editar(lblLimite, TTipoCampo.Valor, 'Limite de Crédito',
                         'Informe o limite', lblLImite.Text, false, 0);

end;

procedure TFrmClienteCad.Image14Click(Sender: TObject);
begin

   FrmEdicao.Editar(lblCNPJ, TTipoCampo.Edit, 'CNPJ/CPF do Cliente',
                    'Informe o CNPJ / CPF', lblCNPJ.Text, true, 20, FormatarCampos)
end;

procedure TFrmClienteCad.Image2Click(Sender: TObject);
begin
  FrmEdicao.Editar(lblNome, TTipoCampo.Edit, 'Nome do Cliente',
                   'Informe o nome', lblNome.Text, true, 100)
end;

procedure TFrmClienteCad.Image3Click(Sender: TObject);
begin
  FrmEdicao.Editar(lblFone, TTipoCampo.Edit, 'Fone do Cliente',
                   'Informe o telefone', lblFone.Text, false, 20, FormatarCampos)
end;

procedure TFrmClienteCad.Image5Click(Sender: TObject);
begin

   FrmEdicao.Editar(lblEmail, TTipoCampo.Edit, 'E-mail do Cliente',
                    'Informe o e-mail', lblEmail.Text, false, 100)

end;

procedure TFrmClienteCad.Image6Click(Sender: TObject);
begin

  FrmEdicao.Editar(lblEndereco, TTipoCampo.Memo, 'Endereço do Cliente',
                   'Informe o endereço', lblEndereco.Text, false, 500)

end;

procedure TFrmClienteCad.Image7Click(Sender: TObject);
begin

  FrmEdicao.Editar(lblNumero, TTipoCampo.Edit, 'Número do Endereço',
                   'Informe o número', lblNumero.Text, false, 50)

end;

procedure TFrmClienteCad.Image8Click(Sender: TObject);
begin

   FrmEdicao.Editar(lblComplemento, TTipoCampo.Edit, 'Complemento do Endereço',
                    'Informe o complemento', lblComplemento.Text, false, 50)

end;

procedure TFrmClienteCad.Image9Click(Sender: TObject);
begin

   FrmEdicao.Editar(lblBairro, TTipoCampo.Edit, 'Bairro do Cliente',
                    'Informe o bairro', lblBairro.Text, false, 50)

end;

procedure TFrmClienteCad.FormatarCampos(Sender: TObject);
begin
    if TLabel(Sender).Name = 'lblCNPJ' then
        Formatar(Sender, TFormato.CNPJorCPF)
    else if TLabel(Sender).Name = 'lblFone' then
        Formatar(Sender, TFormato.TelefoneFixo)
    else if TLabel(Sender).Name = 'lblCEP' then
        Formatar(Sender, TFormato.CEP);
end;

procedure TFrmClienteCad.ListBox1ItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
    if Item.Name = 'lbiCNPJ' then
        FrmEdicao.Editar(lblCNPJ, TTipoCampo.Edit, 'CNPJ/CPF do Cliente',
                         'Informe o CNPJ / CPF', lblCNPJ.Text, true, 20, FormatarCampos)
    else if Item.Name = 'lbiNome' then
        FrmEdicao.Editar(lblNome, TTipoCampo.Edit, 'Nome do Cliente',
                         'Informe o nome', lblNome.Text, true, 100)
    else if Item.Name = 'lbiFone' then
        FrmEdicao.Editar(lblFone, TTipoCampo.Edit, 'Fone do Cliente',
                         'Informe o telefone', lblFone.Text, false, 20, FormatarCampos)
    else if Item.Name = 'lbiEmail' then
        FrmEdicao.Editar(lblEmail, TTipoCampo.Edit, 'E-mail do Cliente',
                         'Informe o e-mail', lblEmail.Text, false, 100)
    else if Item.Name = 'lbiEndereco' then
        FrmEdicao.Editar(lblEndereco, TTipoCampo.Memo, 'Endereço do Cliente',
                         'Informe o endereço', lblEndereco.Text, false, 500)
    else if Item.Name = 'lbiNumero' then
        FrmEdicao.Editar(lblNumero, TTipoCampo.Edit, 'Número do Endereço',
                         'Informe o número', lblNumero.Text, false, 50)
    else if Item.Name = 'lbiComplemento' then
        FrmEdicao.Editar(lblComplemento, TTipoCampo.Edit, 'Complemento do Endereço',
                         'Informe o complemento', lblComplemento.Text, false, 50)
    else if Item.Name = 'lbiBairro' then
        FrmEdicao.Editar(lblBairro, TTipoCampo.Edit, 'Bairro do Cliente',
                         'Informe o bairro', lblBairro.Text, false, 50)
    else if Item.Name = 'lbiCidade' then
        FrmEdicao.Editar(lblCidade, TTipoCampo.Edit, 'Cidade do Cliente',
                         'Informe a cidade', lblCidade.Text, true, 50)
    else if Item.Name = 'lbiUF' then
        combo.ShowMenu
    else if Item.Name = 'lbiCEP' then
        FrmEdicao.Editar(lblCEP, TTipoCampo.Edit, 'CEP do Cliente',
                         'Informe o CEP', lblCEP.Text, false, 10, FormatarCampos)
    else if Item.Name = 'lbiLimite' then
        FrmEdicao.Editar(lblLimite, TTipoCampo.Valor, 'Limite de Crédito',
                         'Informe o limite', lblLImite.Text, false, 0);

end;


end.
