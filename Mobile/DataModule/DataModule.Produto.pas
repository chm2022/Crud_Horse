unit DataModule.Produto;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FMX.Graphics,
  RESTRequest4D, System.Variants, System.JSON;

type
  TDmProduto = class(TDataModule)
    qryConsProduto: TFDQuery;
    qryProduto: TFDQuery;
    TabProduto: TFDMemTable;
  private


    { Private declarations }
  public
    procedure ListarProdutos(pagina: integer; busca, ind_sincronizar: string);
    procedure ListarProdutoId(cod_produto_local, cod_produto_oficial: integer);
    procedure InserirProduto(descricao, ind_sincronizar: string;
                                    valor, qtd_estoque: double;
                                    foto: TBitmap;
                                    cod_produto_oficial: integer);
    procedure EditarProduto(cod_produto_local: integer;
                                   descricao, ind_sincronizar: string;
                                   valor, qtd_estoque: double;
                                   foto: TBitmap);
    procedure ExcluirProduto(cod_produto_local: integer);

  end;

var
  DmProduto: TDmProduto;


implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TDmProduto.ListarProdutos(pagina: integer; busca, ind_sincronizar: string);
begin
    qryConsProduto.Active := false;
    qryConsProduto.SQL.Clear;
    qryConsProduto.SQL.Add('select p.*');
    qryConsProduto.SQL.Add('from tab_produto p ');
    qryConsProduto.SQL.Add('where p.cod_produto_local > 0');

    if busca <> '' then
    begin
        qryConsProduto.SQL.Add('and p.descricao like :descricao');
        qryConsProduto.ParamByName('descricao').Value := '%' + busca + '%';
    end;

    if ind_sincronizar <> '' then
    begin
        qryConsProduto.SQL.Add('and p.ind_sincronizar = :ind_sincronizar');
        qryConsProduto.ParamByName('ind_sincronizar').Value := ind_sincronizar;
    end;

    qryConsProduto.SQL.Add('order by p.descricao');

    if pagina > 0 then
    begin
        qryConsProduto.SQL.Add('limit :pagina, :qtd_reg');
        qryConsProduto.ParamByName('pagina').Value := (pagina - 1) * QTD_REG_PAGINA_PRODUTO;
        qryConsProduto.ParamByName('qtd_reg').Value := QTD_REG_PAGINA_PRODUTO;
    end;

    qryConsProduto.Active := true;
end;

procedure TDmProduto.ListarProdutoId(cod_produto_local, cod_produto_oficial: integer);
begin
    qryProduto.Active := false;
    qryProduto.SQL.Clear;
    qryProduto.SQL.Add('select p.*');
    qryProduto.SQL.Add('from tab_produto p ');
    qryProduto.SQL.Add('where p.cod_produto_local > 0');

    if cod_produto_local > 0 then
    begin
        qryProduto.SQL.Add('and p.cod_produto_local = :cod_produto_local');
        qryProduto.ParamByName('cod_produto_local').Value := cod_produto_local;
    end;

    if cod_produto_oficial > 0 then
    begin
        qryProduto.SQL.Add('and p.cod_produto_oficial = :cod_produto_oficial');
        qryProduto.ParamByName('cod_produto_oficial').Value := cod_produto_oficial;
    end;

    qryProduto.Active := true;
end;

procedure TDmProduto.InserirProduto(descricao, ind_sincronizar: string;
                                    valor, qtd_estoque: double;
                                    foto: TBitmap;
                                    cod_produto_oficial: integer);
begin
    qryProduto.Active := false;
    qryProduto.SQL.Clear;
    qryProduto.SQL.Add('insert into tab_produto(descricao, valor, foto, qtd_estoque, ind_sincronizar, cod_produto_oficial)');
    qryProduto.SQL.Add('values(:descricao, :valor, :foto, :qtd_estoque, :ind_sincronizar, :cod_produto_oficial)');
    qryProduto.ParamByName('descricao').Value := descricao;
    qryProduto.ParamByName('valor').Value := valor;

    if foto <> nil then
        qryProduto.ParamByName('foto').Assign(foto)
    else
    begin
        qryProduto.ParamByName('foto').DataType := ftString;
        qryProduto.ParamByName('foto').Value := Unassigned;
    end;

    qryProduto.ParamByName('qtd_estoque').Value := qtd_estoque;
    qryProduto.ParamByName('ind_sincronizar').Value := ind_sincronizar;
    qryProduto.ParamByName('cod_produto_oficial').Value := cod_produto_oficial;
    qryProduto.ExecSQL;
end;

procedure TDmProduto.EditarProduto(cod_produto_local: integer;
                                   descricao, ind_sincronizar: string;
                                   valor, qtd_estoque: double;
                                   foto: TBitmap);
begin
    qryProduto.Active := false;
    qryProduto.SQL.Clear;
    qryProduto.SQL.Add('update tab_produto set descricao=:descricao, valor=:valor, ');
    qryProduto.SQL.Add('qtd_estoque=:qtd_estoque, ind_sincronizar=:ind_sincronizar');

    if foto <> nil then
    begin
        qryProduto.SQL.Add(', foto=:foto');
        qryProduto.ParamByName('foto').Assign(foto);
    end;

    qryProduto.SQL.Add('where cod_produto_local = :cod_produto_local');
    qryProduto.ParamByName('descricao').Value := descricao;
    qryProduto.ParamByName('valor').Value := valor;
    qryProduto.ParamByName('qtd_estoque').Value := qtd_estoque;
    qryProduto.ParamByName('ind_sincronizar').Value := ind_sincronizar;
    qryProduto.ParamByName('cod_produto_local').Value := cod_produto_local;
    qryProduto.ExecSQL;
end;

procedure TDmProduto.ExcluirProduto(cod_produto_local: integer);
begin
    qryProduto.Active := false;
    qryProduto.SQL.Clear;
    qryProduto.SQL.Add('select * from tab_pedido_item where cod_produto_local = :cod_produto_local');
    qryProduto.ParamByName('cod_produto_local').Value := cod_produto_local;
    qryProduto.Active := true;

    if qryProduto.RecordCount > 0 then
        raise Exception.Create('O produto já está sendo usado por um pedido e não pode ser excluído.');

    qryProduto.Active := false;
    qryProduto.SQL.Clear;
    qryProduto.SQL.Add('delete from tab_produto where cod_produto_local = :cod_produto_local');
    qryProduto.ParamByName('cod_produto_local').Value := cod_produto_local;
    qryProduto.ExecSQL;
end;

end.
