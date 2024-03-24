unit UnitCliente;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.Objects, FMX.Layouts, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView,
  DataModule.cliente;

type
  TFrmCliente = class(TForm)
    rect_top: TRectangle;
    Label3: TLabel;
    Layout8: TLayout;
    img_voltar: TImage;
    rect_bottom: TRectangle;
    lyt_botao: TLayout;
    Layout2: TLayout;
    Circle1: TCircle;
    btn_NovoCliente: TCircle;
    Label13: TLabel;
    rect_form: TRectangle;
    rectBusca: TRectangle;
    edtBuscaCliente: TEdit;
    img_buscarCliente: TImage;
    img_retorna_lista: TImage;
    imgIconeCliente: TImage;
    imgIconeEndereco: TImage;
    imgIconeMenu: TImage;
    imgIconeSincronizar: TImage;
    lvCliente: TListView;
    imgSemCliente: TImage;
    imgIconeFone: TImage;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure img_voltarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure img_buscarClienteClick(Sender: TObject);
    procedure img_retorna_listaClick(Sender: TObject);
    procedure btn_NovoClienteClick(Sender: TObject);
    procedure lvClientePaint(Sender: TObject; Canvas: TCanvas;
      const ARect: TRectF);
    procedure lvClienteUpdateObjects(const Sender: TObject;
      const AItem: TListViewItem);
    procedure FormShow(Sender: TObject);
    procedure lvClienteItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
  private
    { Private declarations }

    menu: TActionSheet;
    fancy: TFancyDialog;

    procedure AddClienteListview(cod_cliente_local, nome, endereco, numero,
                                 complemento, bairro, cidade, uf, fone, ind_sincronizar: string);
    procedure ListarClientes(pagina: integer; busca: string;
                             ind_clear: boolean);
    procedure ThreadClientesTerminate(Sender: TObject);
    procedure ClickAlterarCliente(Sender: TObject);
    procedure ClickExcluirCliente(Sender: TObject);
    procedure ClickDelete(Sender: TObject);


  public
    { Public declarations }
  end;

var
  FrmCliente: TFrmCliente;

  //vcod_cliente : integer;

implementation

{$R *.fmx}

uses UnitClienteCad;

procedure TFrmCliente.btn_NovoClienteClick(Sender: TObject);
begin

  if NOT Assigned(FrmClienteCad) then
    Application.CreateForm(TFrmClienteCad, FrmClienteCad);

  FrmClienteCad.Modo           := 'I';
  FrmClienteCad.Cod_Cliente    := 0;
  FrmClienteCad.ExecuteOnClose := RefreshListagemCliente;
  FrmClienteCad.Show;

end;

procedure TFrmCliente.FormClose(Sender: TObject; var Action: TCloseAction);
begin

  action     := TCloseAction.cafree;
  FrmCliente := nil;

end;

procedure TFrmCliente.ClickDelete(Sender: TObject);
begin
  try

    DmCliente.ExcluirCliente(menu.TagString.ToInteger);

    refreshListagemCliente;

  except on ex:exception do

    fancy.Show(TIconDialog.Error, 'Aviso', ex.Message, 'OK');

  end;

end;

procedure TFrmCliente.ClickExcluirCliente(Sender: TObject);
begin

  menu.HideMenu;

  fancy.Show(TIconDialog.Question, 'Confirmação', 'Confirma a exclusão do cliente?',
             'Sim', ClickDelete, 'Não');

end;

procedure TFrmCliente.ClickAlterarCliente(Sender: TObject);
begin

  menu.HideMenu;

  if NOT Assigned(FrmClienteCad) then
    Application.CreateForm(TFrmClienteCad, FrmClienteCad);

  FrmClienteCad.Modo           := 'A';
  FrmClienteCad.Cod_Cliente    := menu.TagString.ToInteger;
  FrmClienteCad.ExecuteOnClose := RefreshListagemCliente;
  FrmClienteCad.Show;

end;

procedure TFrmCliente.FormCreate(Sender: TObject);
begin

  if NOT Assigned(DmCliente) then
    Application.CreateForm(TDmCliente, DmCliente);


  menu                   := TActionSheet.Create(FrmCliente);
  menu.TitleFontSize     := 12;
  menu.TitleMenuText     := 'Clientes';
  //menu.TitleFontColor    := $FFA3A3A3;

  menu.CancelMenuText    := 'Cancelar';
  menu.CancelFontSize    := 13;
  menu.CancelFontColor   := $FFDA4F3F;

  menu.BackgroundOpacity := 0.5;
  menu.MenuColor         := $FFFFFFFF;

  menu.AddItem('', 'Excluir Cliente', ClickExcluirCliente, $FF774754, 14);
  menu.AddItem('', 'Alterar Cliente', ClickAlterarCliente, $FF774754, 14);


  fancy := TFancyDialog.Create(FrmCliente);

end;

procedure TFrmCliente.FormDestroy(Sender: TObject);
begin

  menu.DisposeOf;
  fancy.DisposeOf;

end;

procedure TFrmCliente.FormShow(Sender: TObject);
begin

  ListarClientes(1, '', true);

end;

procedure TFrmCliente.AddClienteListview(cod_cliente_local, nome, endereco,
                                         numero, complemento, bairro,
                                         cidade, uf, fone,
                                         ind_sincronizar: string);
var
  item: TListViewItem;
  txt: TListItemText;
  img: TListItemImage;
begin

  try

    item := lvCliente.Items.Add;

    with item do
    begin

      Height := 100;
      TagString := cod_cliente_local;

      // Nome...
      txt := TListItemText(Objects.FindDrawable('txtNome'));
      txt.Text := nome;

      // Endereco Completo...
      txt := TListItemText(Objects.FindDrawable('txtEndereco'));
      txt.Text := endereco;

      if numero <> '' then
          txt.Text := txt.Text + ', ' + numero;

      if complemento <> '' then
          txt.Text := txt.Text + ' - ' + complemento;

      if bairro <> '' then
          txt.Text := txt.Text + ' - ' + bairro;

      if cidade<> '' then
          txt.Text := txt.Text + ' - ' + cidade;

      if uf <> '' then
          txt.Text := txt.Text + ' - ' + uf;

      // Fone...
      txt := TListItemText(Objects.FindDrawable('txtFone'));
      txt.Text := fone;

      // Icone Endereco...
      img := TListItemImage(Objects.FindDrawable('imgEndereco'));
      img.Bitmap := imgIconeEndereco.Bitmap;

      // Icone Fone...
      img := TListItemImage(Objects.FindDrawable('imgFone'));
      img.Bitmap := imgIconeFone.Bitmap;

      // Icone Menu...
      img        := TListItemImage(Objects.FindDrawable('imgMenu'));
      img.Bitmap := imgIconeMenu.Bitmap;
      img.TagString := cod_cliente_local;

      // Icone Sincronizacao...
      if ind_sincronizar = 'S' then
      begin
          img := TListItemImage(Objects.FindDrawable('imgSincronizar'));
          img.Bitmap := imgIconeSincronizar.Bitmap;
      end;

    end;

    LayoutListviewCliente(item);

  except on ex:exception do

    fancy.Show(TIconDialog.Error, 'Erro', 'Erro ao inserir cliente na lista: ' + ex.Message, 'OK');

  end;

end;

procedure TFrmCliente.img_buscarClienteClick(Sender: TObject);
begin

   ListarClientes(1, edtBuscaCliente.Text, true);

end;

procedure TFrmCliente.img_retorna_listaClick(Sender: TObject);
begin

  edtBuscaCliente.Text := '';
  ListarClientes(1, edtBuscaCliente.Text, true);

end;

procedure TFrmCliente.img_voltarClick(Sender: TObject);
begin

  close;

end;

procedure TFrmCliente.LayoutListviewCliente(AItem: TListViewItem);
var
  txt: TListItemText;
begin

  txt          := TListItemText(AItem.Objects.FindDrawable('txtEndereco'));
  txt.Width    := lvCliente.Width - 100;
  txt.Height   := GetTextHeight(txt, txt.Width, txt.Text) + 5;

  AItem.Height := Trunc(txt.PlaceOffset.Y + txt.Height);

end;

procedure TFrmCliente.ListarClientes(pagina: integer; busca: string;
  ind_clear: boolean);
var
  t: TThread;
begin

  imgSemCliente.Visible := false;

  // Evitar processamento concorrente...
  if lvCliente.TagString = 'S' then
    exit;

  // Em processamento...
  lvCliente.TagString := 'S';

  lvCliente.BeginUpdate;

  // Limpar a lista...
  if ind_clear then
    begin
      pagina := 1;
      lvCliente.ScrollTo(0);
      lvCliente.Items.Clear;
    end;

  // Salva a pagina atual a ser exibida...
  lvCliente.Tag := pagina;

  // Requisicao por mais dados...
  t := TThread.CreateAnonymousThread(procedure
  begin
    DmCliente.ListarClientes(pagina, busca, '');
  end);

  t.OnTerminate := ThreadClientesTerminate;
  t.Start;

end;

procedure TFrmCliente.lvClienteItemClickEx(const Sender: TObject;
  ItemIndex: Integer; const LocalClickPos: TPointF;
  const ItemObject: TListItemDrawable);
begin

  if Assigned(ItemObject) then
     begin

      if ItemObject.Name = 'imgMenu' then
        begin

          //-- pega o codigo local do item da listview quando clicar na imagem menu
          menu.TagString := itemobject.TagString;

          menu.ShowMenu;

          exit;

        end
     end;

end;

procedure TFrmCliente.lvClientePaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
begin

  // Verifica se a rolagem atingiu o limite para uma nova carga...
  if (lvCliente.Items.Count >= QTD_REG_PAGINA_CLIENTE) and (lvCliente.Tag >= 0) then
    if lvCliente.GetItemRect(lvCliente.Items.Count - 5).Bottom <= lvCliente.Height then
      ListarClientes(lvCliente.Tag + 1, edtBuscaCliente.Text, false);

end;

procedure TFrmCliente.lvClienteUpdateObjects(const Sender: TObject;
  const AItem: TListViewItem);
begin

    LayoutListviewCliente(AItem);

end;

procedure TFrmCliente.RefreshListagemCliente;
begin

  ListarClientes(1, edtBuscaCliente.Text, true);

end;

procedure TFrmCliente.ThreadClientesTerminate(Sender: TObject);
begin

  // Nao carregar mais dados...
  if DmCliente.qryConsCliente.RecordCount < QTD_REG_PAGINA_CLIENTE then
    lvCliente.Tag := -1;

  with DmCliente.qryConsCliente do
  begin
      while NOT EOF do
      begin

          AddClienteListview(fieldbyname('cod_cliente_local').asstring,
                             fieldbyname('nome').asstring,
                             fieldbyname('endereco').asstring,
                             fieldbyname('numero').asstring,
                             fieldbyname('complemento').asstring,
                             fieldbyname('bairro').asstring,
                             fieldbyname('cidade').asstring,
                             fieldbyname('uf').asstring,
                             fieldbyname('fone').asstring,
                             fieldbyname('ind_sincronizar').asstring);

          Next;
      end;

  end;

  lvCliente.EndUpdate;

  // Marcar quer o processo terminou...
  lvCliente.TagString := '';

  // Aviso de tela vazia...
  imgSemCliente.Visible := lvCliente.Items.Count = 0;

  // Deu erro na Thread?
  if Sender is TThread then
    begin

      if Assigned(TThread(Sender).FatalException) then
        begin

          fancy.Show(TIconDialog.Error, 'Erro', Exception(TThread(sender).FatalException).Message, 'OK');
          exit;

        end;

    end;

end;

end.
