unit DataModule.Cliente;

interface

uses
  System.SysUtils, System.Classes,  FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  RESTRequest4D,  System.JSON;

type
  TDmCliente = class(TDataModule)
    qryConsCliente: TFDQuery;
    qryCliente: TFDQuery;
    TabCliente: TFDMemTable;
  private
    { Private declarations }
  public
    procedure ListarClientes(pagina: integer; busca, ind_sincronizar: string);
    procedure EditarCliente(cod_cliente_local: integer;
                                   cnpj_cpf, nome, fone, email, endereco, numero,
                                   complemento, bairro, cidade, uf, cep, ind_sincronizar: string;
                                   limite_disponivel, latitude, longitude: double);
    procedure ExcluirCliente(cod_cliente_local: integer);
    procedure InserirCliente(cnpj_cpf, nome, fone, email, endereco, numero,
                                    complemento, bairro, cidade, uf, cep: string;
                                    limite_disponivel, latitude, longitude: double;
                                    ind_sincronizar: string;
                                    cod_cliente_oficial: integer);
    procedure ListarClienteId(cod_cliente_local, cod_cliente_oficial: integer);

  end;

var
  DmCliente: TDmCliente;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TDmCliente.ListarClientes(pagina: integer; busca, ind_sincronizar: string);
begin
    qryConsCliente.Active := false;
    qryConsCliente.SQL.Clear;
    qryConsCliente.SQL.Add('select c.cod_cliente_local, c.cnpj_cpf, c.nome, c.fone, c.email, c.endereco,');
    qryConsCliente.SQL.Add('c.numero, c.complemento, c.bairro, c.cidade, c.uf, c.cep, c.ind_sincronizar,');
    qryConsCliente.SQL.Add('ifnull(c.latitude, 0) as latitude, ifnull(c.longitude, 0) as longitude, ');
    qryConsCliente.SQL.Add('ifnull(c.limite_disponivel, 0) as limite_disponivel, c.cod_cliente_oficial');
    qryConsCliente.SQL.Add('from tab_cliente c ');
    qryConsCliente.SQL.Add('where c.cod_cliente_local > 0');

    if busca <> '' then
    begin
        qryConsCliente.SQL.Add('and c.nome like :nome');
        qryConsCliente.ParamByName('nome').Value := '%' + busca + '%';
    end;

    if ind_sincronizar <> '' then
    begin
        qryConsCliente.SQL.Add('and c.ind_sincronizar = :ind_sincronizar');
        qryConsCliente.ParamByName('ind_sincronizar').Value := ind_sincronizar;
    end;

    qryConsCliente.SQL.Add('order by c.nome');

    if pagina > 0 then
    begin
        qryConsCliente.SQL.Add('limit :pagina, :qtd_reg');
        qryConsCliente.ParamByName('pagina').Value := (pagina - 1) * QTD_REG_PAGINA_CLIENTE;
        qryConsCliente.ParamByName('qtd_reg').Value := QTD_REG_PAGINA_CLIENTE;
    end;

    qryConsCliente.Active := true;
end;

procedure TDmCliente.ListarClienteId(cod_cliente_local, cod_cliente_oficial: integer);
begin
    qryCliente.Active := false;
    qryCliente.SQL.Clear;
    qryCliente.SQL.Add('select c.cod_cliente_local, c.cnpj_cpf, c.nome, c.fone, c.email, c.endereco,');
    qryCliente.SQL.Add('c.numero, c.complemento, c.bairro, c.cidade, c.uf, c.cep, c.ind_sincronizar,');
    qryCliente.SQL.Add('ifnull(c.latitude, 0) as latitude, ifnull(c.longitude, 0) as longitude, ');
    qryCliente.SQL.Add('ifnull(c.limite_disponivel, 0) as limite_disponivel, c.cod_cliente_oficial');
    qryCliente.SQL.Add('from tab_cliente c ');
    qryCliente.SQL.Add('where c.cod_cliente_local > 0');

    if cod_cliente_local > 0 then
    begin
        qryCliente.SQL.Add('and c.cod_cliente_local = :cod_cliente_local');
        qryCliente.ParamByName('cod_cliente_local').Value := cod_cliente_local;
    end;

    if cod_cliente_oficial > 0 then
    begin
        qryCliente.SQL.Add('and c.cod_cliente_oficial = :cod_cliente_oficial');
        qryCliente.ParamByName('cod_cliente_oficial').Value := cod_cliente_oficial;
    end;

    qryCliente.Active := true;
end;

procedure TDmCliente.InserirCliente(cnpj_cpf, nome, fone, email, endereco, numero,
                                    complemento, bairro, cidade, uf, cep: string;
                                    limite_disponivel, latitude, longitude: double;
                                    ind_sincronizar: string;
                                    cod_cliente_oficial: integer);
begin
    qryCliente.Active := false;
    qryCliente.SQL.Clear;
    qryCliente.SQL.Add('insert into tab_cliente(cnpj_cpf, nome, fone, email, endereco, numero,');
    qryCliente.SQL.Add('complemento, bairro, cidade, uf, cep, limite_disponivel, ind_sincronizar,');
    qryCliente.SQL.add('latitude, longitude, cod_cliente_oficial)');
    qryCliente.SQL.Add('values(:cnpj_cpf, :nome, :fone, :email, :endereco, :numero,');
    qryCliente.SQL.Add(':complemento, :bairro, :cidade, :uf, :cep, :limite_disponivel, :ind_sincronizar,');
    qryCliente.SQL.add(':latitude, :longitude, :cod_cliente_oficial)');

    qryCliente.ParamByName('cnpj_cpf').Value := cnpj_cpf;
    qryCliente.ParamByName('nome').Value := nome;
    qryCliente.ParamByName('fone').Value := fone;
    qryCliente.ParamByName('email').Value := email;
    qryCliente.ParamByName('endereco').Value := endereco;
    qryCliente.ParamByName('numero').Value := numero;
    qryCliente.ParamByName('complemento').Value := complemento;
    qryCliente.ParamByName('bairro').Value := bairro;
    qryCliente.ParamByName('cidade').Value := cidade;
    qryCliente.ParamByName('uf').Value := uf;
    qryCliente.ParamByName('cep').Value := cep;
    qryCliente.ParamByName('limite_disponivel').Value := limite_disponivel;
    qryCliente.ParamByName('latitude').Value := latitude;
    qryCliente.ParamByName('longitude').Value := longitude;
    qryCliente.ParamByName('cod_cliente_oficial').Value := cod_cliente_oficial;
    qryCliente.ParamByName('ind_sincronizar').Value := ind_sincronizar;

    qryCliente.ExecSQL;
end;

procedure TDmCliente.EditarCliente(cod_cliente_local: integer;
                                   cnpj_cpf, nome, fone, email, endereco, numero,
                                   complemento, bairro, cidade, uf, cep, ind_sincronizar: string;
                                   limite_disponivel, latitude, longitude: double);
begin
    qryCliente.Active := false;
    qryCliente.SQL.Clear;
    qryCliente.SQL.Add('update tab_cliente set cnpj_cpf=:cnpj_cpf, nome=:nome, fone=:fone, ');
    qryCliente.SQL.Add('email=:email, endereco=:endereco, numero=:numero,');
    qryCliente.SQL.Add('complemento=:complemento, bairro=:bairro, cidade=:cidade, uf=:uf,');
    qryCliente.SQL.Add('cep=:cep, limite_disponivel=:limite_disponivel, ind_sincronizar=:ind_sincronizar,');
    qryCliente.SQL.Add('latitude=:latitude, longitude=:longitude ');
    qryCliente.SQL.Add('where cod_cliente_local=:cod_cliente_local');

    qryCliente.ParamByName('cnpj_cpf').Value := cnpj_cpf;
    qryCliente.ParamByName('nome').Value := nome;
    qryCliente.ParamByName('fone').Value := fone;
    qryCliente.ParamByName('email').Value := email;
    qryCliente.ParamByName('endereco').Value := endereco;
    qryCliente.ParamByName('numero').Value := numero;
    qryCliente.ParamByName('complemento').Value := complemento;
    qryCliente.ParamByName('bairro').Value := bairro;
    qryCliente.ParamByName('cidade').Value := cidade;
    qryCliente.ParamByName('uf').Value := uf;
    qryCliente.ParamByName('cep').Value := cep;
    qryCliente.ParamByName('limite_disponivel').Value := limite_disponivel;
    qryCliente.ParamByName('ind_sincronizar').Value := ind_sincronizar;
    qryCliente.ParamByName('latitude').Value := latitude;
    qryCliente.ParamByName('longitude').Value := longitude;
    qryCliente.ParamByName('cod_cliente_local').Value := cod_cliente_local;
    qryCliente.ExecSQL;
end;

end.
