unit UnitProdutoCad;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Objects, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Layouts,
  System.Actions, FMX.ActnList, FMX.StdActns,
  FMX.MediaLibrary.Actions, DataModule.Produto,
  Data.DB, FMX.DialogService;

type
  TExecuteOnClose = procedure of Object;

  TFrmProdutoCad = class(TForm)
    rectToolbar: TRectangle;
    lblTitulo: TLabel;
    btnVoltar: TSpeedButton;
    Image4: TImage;
    btnSalvar: TSpeedButton;
    Image1: TImage;
    Layout1: TLayout;
    imgFoto: TImage;
    Label1: TLabel;
    rectDescricao: TRectangle;
    Label2: TLabel;
    Image14: TImage;
    lblDescricao: TLabel;
    rectValor: TRectangle;
    Label3: TLabel;
    Image2: TImage;
    lblValor: TLabel;
    rectEstoque: TRectangle;
    Label4: TLabel;
    Image3: TImage;
    lblEstoque: TLabel;
    ActionList1: TActionList;
    ActBibliotecaFotos: TTakePhotoFromLibraryAction;
    ActCamera: TTakePhotoFromCameraAction;
    OpenDialog: TOpenDialog;
    Layout2: TLayout;
    btnExcluir: TSpeedButton;
    Image5: TImage;
    procedure btnVoltarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure imgFotoClick(Sender: TObject);
    procedure ActBibliotecaFotosDidFinishTaking(Image: TBitmap);
    procedure rectDescricaoClick(Sender: TObject);
    procedure rectValorClick(Sender: TObject);
    procedure rectEstoqueClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
  private
    FCod_produto: integer;
    FModo: string;
    FExecuteOnClose: TExecuteOnClose;
    procedure ClickBibliotecaFotos(Sender: TObject);
    procedure ClickTirarFoto(Sender: TObject);
    procedure ErroPermissaoFotos(Sender: TObject);
    procedure ClickDelete(Sender: TObject);
  public
    property Modo: string read FModo write FModo;
    property Cod_Produto: integer read FCod_produto write FCod_produto;
    property ExecuteOnClose: TExecuteOnClose read FExecuteOnClose write FExecuteOnClose;
  end;

var
  FrmProdutoCad: TFrmProdutoCad;

implementation

{$R *.fmx}

uses UnitPrincipal;

procedure TFrmProdutoCad.ActBibliotecaFotosDidFinishTaking(Image: TBitmap);
begin
    imgFoto.Bitmap := Image;
end;

procedure TFrmProdutoCad.ClickDelete(Sender: TObject);
begin
    try
        DmProduto.ExcluirProduto(Cod_Produto);

        if Assigned(ExecuteOnClose) then
            ExecuteOnClose;

        close;
    except on ex:exception do
        fancy.Show(TIconDialog.Warning, 'Aviso', ex.Message, 'OK');
    end;
end;

procedure TFrmProdutoCad.btnExcluirClick(Sender: TObject);
begin
    fancy.Show(TIconDialog.Question, 'Confirmação', 'Confirma a exclusão do produto?',
               'Sim', ClickDelete, 'Não');
end;

procedure TFrmProdutoCad.btnSalvarClick(Sender: TObject);
begin
    if lblDescricao.Text = '' then
    begin
        fancy.Show(TIconDialog.Warning, 'Aviso', 'Informe a descrição do produto', 'OK');
        exit;
    end;

    try
        if Modo = 'I' then
            DmProduto.InserirProduto(lblDescricao.Text,
                                     'S',
                                     StringToFloat(lblValor.Text),
                                     lblEstoque.Text.ToInteger,
                                     imgFoto.Bitmap,
                                     0)
        else
            DmProduto.EditarProduto(Cod_Produto,
                                    lblDescricao.Text,
                                    'S',
                                    StringToFloat(lblValor.Text),
                                    lblEstoque.Text.ToInteger,
                                    imgFoto.Bitmap);

        if Assigned(ExecuteOnClose) then
            ExecuteOnClose;

        close;

    except on ex:exception do
        fancy.Show(TIconDialog.Error, 'Erro', 'Erro ao salvar dados do produto: ' + ex.Message, 'OK');
    end;
end;

procedure TFrmProdutoCad.btnVoltarClick(Sender: TObject);
begin
    close;
end;

procedure TFrmProdutoCad.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := TCloseAction.caFree;
    FrmProdutoCad := nil;
end;

procedure TFrmProdutoCad.ErroPermissaoFotos(Sender: TObject);
begin
    fancy.Show(TIconDialog.Error, 'Permissão', 'Você não possui acesso a esse recurso no aparelho', 'OK');
end;

procedure TFrmProdutoCad.ClickBibliotecaFotos(Sender: TObject);
begin
    menu.HideMenu;

    permissao.PhotoLibrary(ActBibliotecaFotos, ErroPermissaoFotos);
end;

procedure TFrmProdutoCad.ClickTirarFoto(Sender: TObject);
begin
    menu.HideMenu;

    permissao.Camera(ActCamera, ErroPermissaoFotos);
end;

procedure TFrmProdutoCad.FormCreate(Sender: TObject);
begin
    permissao := T99Permissions.Create;
    fancy := TFancyDialog.Create(FrmProdutoCad);

end;

procedure TFrmProdutoCad.FormDestroy(Sender: TObject);
begin
    menu.DisposeOf;
    permissao.DisposeOf;
    fancy.DisposeOf;
end;

procedure TFrmProdutoCad.FormShow(Sender: TObject);
begin
    try
        btnExcluir.Visible := Modo = 'A';

        if Modo = 'A' then
        begin
            DmProduto.ListarProdutoId(Cod_Produto, 0);

            if DmProduto.qryProduto.FieldByName('foto').AsString <> '' then
                LoadBitmapFromBlob(imgFoto.Bitmap, TBlobField(DmProduto.qryProduto.FieldByName('foto')));

            lblDescricao.Text := DmProduto.qryProduto.FieldByName('descricao').AsString;
            lblValor.Text := FormatFloat('#,##0.00', DmProduto.qryProduto.FieldByName('valor').AsFloat);
            lblEstoque.Text := FormatFloat('#,##0', DmProduto.qryProduto.FieldByName('qtd_estoque').AsFloat);
            lblTitulo.Text := 'Editar Produto';
        end;
    except on ex:exception do
        fancy.Show(TIconDialog.Error, 'Erro', 'Erro ao carregar dados do produto: ' + ex.Message, 'OK');
    end;
end;

procedure TFrmProdutoCad.imgFotoClick(Sender: TObject);
begin
    {$IFDEF MSWINDOWS}
    If OpenDialog.Execute then
        imgFoto.Bitmap.LoadFromFile(OpenDialog.FileName);
    {$ELSE}
    menu.ShowMenu;
    {$ENDIF}
end;

procedure TFrmProdutoCad.rectDescricaoClick(Sender: TObject);
begin
    FrmEdicao.Editar(lblDescricao,
                     TTipoCampo.Memo,
                     'Descrição do Produto',
                     'Informe a descrição',
                     lblDescricao.Text,
                     true,
                     200
                     );
end;

procedure TFrmProdutoCad.rectEstoqueClick(Sender: TObject);
begin
    FrmEdicao.Editar(lblEstoque,
                     TTipoCampo.Inteiro,
                     'Qtd em Estoque',
                     '',
                     lblEstoque.Text,
                     true,
                     0,
                     );
end;

procedure TFrmProdutoCad.rectValorClick(Sender: TObject);
begin
    FrmEdicao.Editar(lblValor,
                     TTipoCampo.Valor,
                     'Valor do Produto',
                     '',
                     lblValor.Text,
                     true,
                     0
                     );
end;

end.
