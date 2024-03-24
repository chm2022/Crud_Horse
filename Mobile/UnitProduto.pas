unit UnitProduto;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Edit, FMX.Objects, FMX.StdCtrls, FMX.Controls.Presentation,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, DataModule.Produto, Data.DB, UnitProdutoCad,
  FMX.Layouts;

type
  TFrmProduto = class(TForm)
    rectToolbar: TRectangle;
    Label3: TLabel;
    lvProduto: TListView;
    imgIconeEstoque: TImage;
    imgIconeValor: TImage;
    imgIconeCamera: TImage;
    imgSemProduto: TImage;
    imgIconeSincronizar: TImage;
    rect_bottom: TRectangle;
    Circle1: TCircle;
    Circle2: TCircle;
    lyt_botao: TLayout;
    Layout2: TLayout;
    Label13: TLabel;
    rectBusca: TRectangle;
    edtBuscaProduto: TEdit;
    Image2: TImage;
    Image3: TImage;
    imgIconeMenu: TImage;
    Layout1: TLayout;
    btnVoltar: TSpeedButton;
    Image4: TImage;
    procedure FormShow(Sender: TObject);
    procedure btnBuscaProdutoClick(Sender: TObject);
    procedure lvProdutoPaint(Sender: TObject; Canvas: TCanvas;
      const ARect: TRectF);
    procedure lvProdutoUpdateObjects(const Sender: TObject;
      const AItem: TListViewItem);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lvProdutoItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnVoltarClick(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure Circle2Click(Sender: TObject);
  private
    procedure AddProdutoListview(cod_produto_local, descricao: string;
                                         valor, estoque: double;
                                         foto: TStream;
                                         ind_sincronizar: string);
    procedure ListarProdutos(pagina: integer; busca: string;
      ind_clear: boolean);
    procedure RefreshListagem;

    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmProduto: TFrmProduto;


implementation

{$R *.fmx}

uses UnitPrincipal;

procedure TFrmProduto.AddProdutoListview(cod_produto_local, descricao: string;
                                         valor, estoque: double;
                                         foto: TStream;
                                         ind_sincronizar: string);
var
    item: TListViewItem;
    txt: TListItemText;
    img: TListItemImage;
    bmp: TBitmap;
begin
    try
        item := lvProduto.Items.Add;

        with item do
        begin
            Height := 90;
            TagString := cod_produto_local;

            // Descricao...
            txt := TListItemText(Objects.FindDrawable('txtDescricao'));
            txt.Text := descricao;

            // Valor Unitario...
            txt := TListItemText(Objects.FindDrawable('txtValor'));
            txt.Text := FormatFloat('R$#,##0.00', valor);

            // Valor Cento...
            txt := TListItemText(Objects.FindDrawable('txtValorPromo'));
            txt.Text := FormatFloat('R$#,##0.00', 0);

            // Estoque...
            txt := TListItemText(Objects.FindDrawable('txtEstoque'));
            txt.Text := FormatFloat('#,##', estoque);

             // Icone Menu...
            img        := TListItemImage(Objects.FindDrawable('imgMenu'));
            img.Bitmap := imgIconeMenu.Bitmap;

            // Icone Valor...
            img := TListItemImage(Objects.FindDrawable('imgValor'));
            img.Bitmap := imgIconeValor.Bitmap;

            // Icone Estoque...
            img := TListItemImage(Objects.FindDrawable('imgEstoque'));
            img.Bitmap := imgIconeEstoque.Bitmap;

            // Foto...
            img := TListItemImage(Objects.FindDrawable('imgFoto'));
            if foto <> nil then
            begin
                bmp := TBitmap.Create;
                bmp.LoadFromStream(foto);

                img.OwnsBitmap := true;
                img.Bitmap := bmp;
            end
            else
                img.Bitmap := imgIconeCamera.Bitmap;

            // Icone Sincronizacao...
            if ind_sincronizar = 'S' then
            begin
                img := TListItemImage(Objects.FindDrawable('imgSincronizar'));
                img.Bitmap := imgIconeSincronizar.Bitmap;
            end;
        end;

        LayoutListviewProduto(item);

    except on ex:exception do
        fancy.Show(TIconDialog.Error, 'Erro', 'Erro ao inserir pedido na lista: ' + ex.Message, 'OK');
    end;
end;


procedure TFrmProduto.btnBuscaProdutoClick(Sender: TObject);
begin
    ListarProdutos(1, edtBuscaProduto.Text, true);
end;

procedure TFrmProduto.btnVoltarClick(Sender: TObject);
begin
    close;
end;

procedure TFrmProduto.Circle2Click(Sender: TObject);
begin

  if NOT Assigned(FrmProdutoCad) then
        Application.CreateForm(TFrmProdutoCad, FrmProdutoCad);

    FrmProdutoCad.Modo := 'I';
    FrmProdutoCad.Cod_Produto := 0;
    FrmProdutoCad.ExecuteOnClose := RefreshListagem;
    FrmProdutoCad.Show;

end;

procedure TFrmProduto.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := TCloseAction.caFree;
    FrmProduto := nil;
end;

procedure TFrmProduto.FormCreate(Sender: TObject);
begin

   if NOT Assigned(DmProduto) then
        Application.CreateForm(TDmProduto, DmProduto);

    fancy := TFancyDialog.Create(FrmProduto);
end;

procedure TFrmProduto.FormDestroy(Sender: TObject);
begin
    fancy.DisposeOf;
end;

procedure TFrmProduto.FormShow(Sender: TObject);
begin
    ListarProdutos(1, '', true);
end;

procedure TFrmProduto.Image2Click(Sender: TObject);
begin
   ListarProdutos(1, edtBuscaProduto.Text, true);
end;

procedure TFrmProduto.ListarProdutos(pagina: integer; busca: string; ind_clear: boolean);
var
    t: TThread;
begin
    imgSemProduto.Visible := false;

    // Evitar processamento concorrente...
    if lvProduto.TagString = 'S' then
        exit;

    // Em processamento...
    lvProduto.TagString := 'S';

    lvProduto.BeginUpdate;

    // Limpar a lista...
    if ind_clear then
    begin
        pagina := 1;
        lvProduto.ScrollTo(0);
        lvProduto.Items.Clear;
    end;

end;

procedure TFrmProduto.lvProdutoItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
     if NOT Assigned(FrmProdutoCad) then
        Application.CreateForm(TFrmProdutoCad, FrmProdutoCad);

    FrmProdutoCad.Modo := 'A';
    FrmProdutoCad.Cod_Produto := AItem.TagString.ToInteger;
    FrmProdutoCad.ExecuteOnClose := RefreshListagem;
    FrmProdutoCad.Show;
end;

procedure TFrmProduto.RefreshListagem;
begin
    ListarProdutos(1, edtBuscaProduto.Text, true);
end;

end.
