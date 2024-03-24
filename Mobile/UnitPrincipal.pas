unit UnitPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.TabControl, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Edit,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FMX.ListBox, DataModule.Cliente, FireDAC.Comp.Client,
  UnitProduto, FMX.Memo.Types, Data.DB,
  FMX.ScrollBox, FMX.Memo, FMX.Ani;

type

  TFrmPrincipal = class(TForm)
    TabControl: TTabControl;
    TabDashboard: TTabItem;
    TabPedido: TTabItem;
    TabCliente: TTabItem;
    TabNotificacao: TTabItem;
    TabMais: TTabItem;
    rectToolbarDashboard: TRectangle;
    Label1: TLabel;
    Rectangle1: TRectangle;
    Label2: TLabel;
    Rectangle2: TRectangle;
    Label3: TLabel;
    Rectangle3: TRectangle;
    Label4: TLabel;
    Rectangle4: TRectangle;
    Label5: TLabel;
    StyleBook1: TStyleBook;
    lvNotificacao: TListView;
    imgSemNotificacao: TImage;
    Circle1: TCircle;
    lyt_menu_botoes: TLayout;
    rect_tabs: TRectangle;
    layout_aba1: TLayout;
    img_aba1: TImage;
    layout_aba2: TLayout;
    img_aba2: TImage;
    layout_aba3: TLayout;
    img_aba3: TImage;
    layout_aba4: TLayout;
    img_aba4: TImage;
    rect_menu_lateral: TRectangle;
    AnimationWidth: TFloatAnimation;
    lytmenu_lateral: TLayout;
    rect_mlateral_cliente: TRectangle;
    Label6: TLabel;
    rect_mlateral_sincro: TRectangle;
    Label7: TLabel;
    rect_mlateral_perfil: TRectangle;
    Label13: TLabel;
    rect_mlateral_produto: TRectangle;
    Label14: TLabel;
    lyt_botao_menu: TLayout;
    rect_menu1: TRectangle;
    Animation1Rotate: TFloatAnimation;
    Animation1Width: TFloatAnimation;
    Animation1Margin: TFloatAnimation;
    Image1: TImage;
    rect_fechar_menu: TRectangle;
    Image3: TImage;
    rect_mlateral_logout: TRectangle;
    Label15: TLabel;
    Layout1: TLayout;
    Layout2: TLayout;
    lbProdutos: TListBox;
    imgFotoExemplo: TImage;
    Rectangle5: TRectangle;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Rectangle6: TRectangle;
    Label16: TLabel;
    lbMaisVendido: TListBox;
    Rectangle7: TRectangle;
    procedure FormShow(Sender: TObject);


    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure layout_aba4Click(Sender: TObject);
    procedure layout_aba1Click(Sender: TObject);
    procedure rect_menu1Click(Sender: TObject);
    procedure rect_fechar_menuClick(Sender: TObject);
    procedure rect_mlateral_clienteClick(Sender: TObject);
    procedure rect_mlateral_produtoClick(Sender: TObject);
    procedure rect_mlateral_perfilClick(Sender: TObject);
    procedure rect_mlateral_sincroClick(Sender: TObject);
    procedure rect_mlateral_logoutClick(Sender: TObject);
    procedure lbProdutosViewportPositionChange(Sender: TObject;
      const OldViewportPosition, NewViewportPosition: TPointF;
      const ContentSizeChanged: Boolean);
    procedure FormResize(Sender: TObject);
    procedure lbProdutosItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
  private

    thread_notif: TThread;
    menu_notificacao: TActionSheet;
    menu: TActionSheet;
    fancy: TFancyDialog;

    procedure CloseMenu;
    procedure OpenMenu;
    procedure Botao_AbrirFechar_menu;

    procedure ListarProdutos(pagina: integer; busca: string; ind_clear: boolean);
    procedure ThreadProdutosTerminate(Sender: TObject);
    procedure AddProdutoListBox(id_produto: string;
                                descricao: string;
                                valor: double;
                                foto: TBitmap);

    procedure Listar_mais_vendidos;



    { Private declarations }
  public
    { Public declarations }

  end;

var
  FrmPrincipal: TFrmPrincipal;

Const
  //-- Quantidade de registros que quero trazer por pagina
  TAM_PAGINA = 14;

implementation

{$R *.fmx}

uses UnitClienteCad, UnitLogin, DataModule.Usuario,
     DataModule.Produto, UnitCliente, Frame.Produto;

procedure TFrmPrincipal.layout_aba1Click(Sender: TObject);
begin
  TabControl.GotoVisibleTab(0);
end;

procedure TFrmPrincipal.layout_aba4Click(Sender: TObject);
begin

  TabControl.GotoVisibleTab(4);

end;

procedure TFrmPrincipal.lbProdutosItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin

  //--
  showmessage('codigo :' + item.Tag.ToString +' descricao :'+ item.TagString);

end;

procedure TFrmPrincipal.lbProdutosViewportPositionChange(Sender: TObject;
  const OldViewportPosition, NewViewportPosition: TPointF;
  const ContentSizeChanged: Boolean);
var
  item: TListBoxItem;
begin

  if (lbProdutos.Items.Count >= TAM_PAGINA) and (lbProdutos.Tag >= 0) then
    begin

      item := lbProdutos.ItemByPoint(30, lbProdutos.Height - 40);

      if (item <> nil) then
        if item.Index >= lbProdutos.Items.Count - 5 then
          ListarProdutos(lbProdutos.Tag + 1, '', false);

    end;

end;

procedure TFrmPrincipal.AddProdutoListBox(id_produto, descricao: string;
                                          valor: double; foto: TBitmap);
var
    item: TListBoxItem;
    frame: TFrameProduto;
    bmp: TBitmap;
begin

  //-- Instanciar um novo item pra listbox
  item := TListBoxItem.Create(lbProdutos);
  item.Selectable := false;        // tira o contorno cinza ao esta selecionado
  item.Text       := '';           //  vem do frame
  item.Height     := 162;
  item.Tag        := id_produto.ToInteger;  //--

  item.TagString  := descricao;

  //-- instanciar o frame
  frame           := TFrameProduto.Create(item);
  frame.hittest   := false;                 //-- tira o click
  frame.Align     := TAlignLayout.Client;   //-- alinha o tamanho

  frame.imgFoto.Bitmap     := foto; //bmp;
  frame.lblDescricao.Text  := descricao;
  frame.lblValor.Text      := FormatFloat('R$#,##0.00', valor);

  //-- Inserir o frame dentro do item da listbox
  item.AddObject(frame);

  //-- insere o item criado dentro da listbox
  lbProdutos.AddObject(item);

end;

procedure TFrmPrincipal.ListarProdutos(pagina: integer; busca: string; ind_clear: boolean);
var
  t: TThread;
begin

  if lbProdutos.TagString = 'S' then
    exit;

  lbProdutos.TagString := 'S';

  lbProdutos.BeginUpdate;

  if ind_clear then
    begin

      pagina := 1;

      lbProdutos.ScrollToItem(lbProdutos.ItemByIndex(0));
      //-- Limpar nosssa lista
      lbProdutos.Items.Clear;
    end;

  lbProdutos.Tag := pagina;

  t := TThread.CreateAnonymousThread(procedure
  begin

    DmProduto.ListarProdutos(pagina, busca, '');

  end);

  t.OnTerminate := ThreadProdutosTerminate;
  t.Start;

end;

procedure TFrmPrincipal.carregartelainicial;
var
    t: TThread;
begin
    TLoading.Show(FrmPrincipal, '');

    //edtNome.Text := Nome;
    //edtEmail.Text := Email;

    //banners.DeleteAll;
    lbProdutos.Items.Clear;
    lbMaisVendido.Items.Clear;

end;

procedure TFrmPrincipal.rect_fechar_menuClick(Sender: TObject);
begin

  botao_AbrirFechar_menu;

end;

procedure TFrmPrincipal.rect_menu1Click(Sender: TObject);
begin

  rect_menu1.visible       := false;
  rect_fechar_menu.visible := true;

  OpenMenu;

end;


procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
    // Modulo de dados...
    if NOT Assigned(DmUsuario) then
        Application.CreateForm(TDmUsuario, DmUsuario);
    if NOT Assigned(DmCliente) then
        Application.CreateForm(TDmCliente, DmCliente);
    if NOT Assigned(DmProduto) then
        Application.CreateForm(TDmProduto, DmProduto);

   rect_menu_lateral.Width := 0;

   fancy := TFancyDialog.Create(FrmPrincipal);

end;

procedure TFrmPrincipal.FormDestroy(Sender: TObject);
begin

  menu.DisposeOf;
  fancy.DisposeOf;

end;

procedure TFrmPrincipal.FormShow(Sender: TObject);
begin

  TabControl.GotoVisibleTab(0);

  Carregartelainicial;

end;

end.
