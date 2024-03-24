unit DataModule.Global;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, FireDAC.FMXUI.Wait, FireDAC.Phys.IBBase, Data.DB,
  FireDAC.Comp.Client, System.IniFiles, FireDAC.DApt, System.JSON,
  DataSet.Serialize, DataSet.Serialize.Config, uMD5, FMX.Graphics,
  SYstem.Variants;

type
  TDmGlobal = class(TDataModule)
    Conn: TFDConnection;
    FDPhysFBDriverLink: TFDPhysFBDriverLink;
    procedure DataModuleCreate(Sender: TObject);
    procedure ConnBeforeConnect(Sender: TObject);
  private

    procedure CarregarConfigDB(Connection: TFDConnection);

  public

    function Login(email, senha: string): TJsonObject;

    //-- USUARIOS ---------------------------------------------------------------
    function InserirUsuario(nome, email, senha: string): TJsonObject;
    function EditarUsuario(cod_usuario: integer; nome, email: string): TJsonObject;
    function ExcluirUsuario(cod_usuario: integer): TJsonObject;

    function EditarSenha(cod_usuario: integer; senha: string): TJsonObject;

    function Push(cod_usuario: integer; token_push: string): TJsonObject;

    function ListarNotificacoes(cod_usuario: integer): TJsonArray;

    //--- CLIENTES --------------------------------------------------------
    function InserirEditarCliente(cod_usuario, cod_cliente_local: integer;
                                  cnpj_cpf, nome, fone, email, endereco, numero,
                                  complemento, bairro, cidade, uf, cep: string;
                                  latitude, longitude, limite_disponivel: double;
                                  cod_cliente_oficial: integer;
                                  dt_ult_sincronizacao: string): TJsonObject;

    function ListarClientes(dt_ult_sincronizacao: string; pagina: integer): TJsonArray;


    //--- PRODUTOS ----------------------------------------------
    function InserirEditarProduto(cod_usuario, cod_produto_local: integer;
                                  descricao: string;
                                  valor, qtd_estoque: double;
                                  cod_produto_oficial: integer;
                                  dt_ult_sincronizacao: string): TJsonObject;

    function ListarProdutos(dt_ult_sincronizacao: string;
                            pagina: integer): TJsonArray;


  end;

var
  DmGlobal: TDmGlobal;

Const
  QTD_REG_PAGINA_CLIENTE     = 5;
  QTD_REG_PAGINA_PRODUTO     = 5;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TDmGlobal.CarregarConfigDB(Connection: TFDConnection);
var
    ini : TIniFile;
    arq: string;
begin
    try
        // Caminho do INI...
        arq := ExtractFilePath(ParamStr(0)) + 'config.ini';

        // Validar arquivo INI...
        if NOT FileExists(arq) then
            raise Exception.Create('Arquivo INI não encontrado: ' + arq);

        // Instanciar arquivo INI...
        ini := TIniFile.Create(arq);
        Connection.DriverName := ini.ReadString('Banco de Dados', 'DriverID', '');

        // Buscar dados do arquivo fisico...
        with Connection.Params do
        begin
            Clear;
            Add('DriverID=' + ini.ReadString('Banco de Dados', 'DriverID', ''));
            Add('Database=' + ini.ReadString('Banco de Dados', 'Database', ''));
            Add('User_Name=' + ini.ReadString('Banco de Dados', 'User_name', ''));
            Add('Password=' + ini.ReadString('Banco de Dados', 'Password', ''));

            if ini.ReadString('Banco de Dados', 'Port', '') <> '' then
                Add('Port=' + ini.ReadString('Banco de Dados', 'Port', ''));

            if ini.ReadString('Banco de Dados', 'Server', '') <> '' then
                Add('Server=' + ini.ReadString('Banco de Dados', 'Server', ''));

            if ini.ReadString('Banco de Dados', 'Protocol', '') <> '' then
                Add('Protocol=' + ini.ReadString('Banco de Dados', 'Protocol', ''));

            if ini.ReadString('Banco de Dados', 'VendorLib', '') <> '' then
                FDPhysFBDriverLink.VendorLib := ini.ReadString('Banco de Dados', 'VendorLib', '');
        end;

    finally
        if Assigned(ini) then
            ini.DisposeOf;
    end;
end;

procedure TDmGlobal.ConnBeforeConnect(Sender: TObject);
begin
    CarregarConfigDB(Conn);
end;

procedure TDmGlobal.DataModuleCreate(Sender: TObject);
begin
    TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndLower;
    TDataSetSerializeConfig.GetInstance.Import.DecimalSeparator := '.';

    Conn.Connected := true;
end;

function TDmGlobal.Login(email, senha: string): TJsonObject;
var
    qry: TFDQuery;
begin
    if (email = '') or (senha = '') then
        raise Exception.Create('Informe o e-mail e a senha');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        with qry do
        begin
            Active := false;
            SQL.Clear;
            SQL.Add('select cod_usuario, nome, email');
            SQL.Add('from tab_usuario');
            SQL.Add('where email = :email and senha = :senha');

            ParamByName('email').Value := email;
            ParamByName('senha').Value := SaltPassword(senha);

            Active := true;
        end;

        Result := qry.ToJSONObject;

    finally
        FreeAndNil(qry);
    end;
end;

function TDmGlobal.InserirUsuario(nome, email, senha: string): TJsonObject;
var
    qry: TFDQuery;
begin
    if (nome = '') or (email = '') or (senha = '') then
        raise Exception.Create('Informe nome, e-mail e senha do usuário');

    if (senha.Length < 5) then
        raise Exception.Create('A senha deve conter pelos menos 5 caracteres');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        with qry do
        begin
            // Validacao do email...
            Active := false;
            SQL.Clear;
            SQL.Add('select cod_usuario from tab_usuario');
            SQL.Add('where email = :email');
            ParamByName('email').Value := email;
            Active := true;

            if RecordCount > 0 then
                raise Exception.Create('Esse e-mail já está em uso por outra conta de usuário');

            Active := false;
            SQL.Clear;
            SQL.Add('insert into tab_usuario(nome, email, senha, ind_excluido)');
            SQL.Add('values(:nome, :email, :senha, :ind_excluido)');
            SQL.Add('returning cod_usuario');

            ParamByName('nome').Value := nome;
            ParamByName('email').Value := email;
            ParamByName('senha').Value := SaltPassword(senha);
            ParamByName('ind_excluido').Value := 'N';

            Active := true;
        end;

        Result := qry.ToJSONObject;

    finally
        FreeAndNil(qry);
    end;
end;

function TDmGlobal.Push(cod_usuario: integer; token_push: string): TJsonObject;
var
    qry: TFDQuery;
begin
    if (token_push = '') then
        raise Exception.Create('Informe o token push do usuário');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        with qry do
        begin
            Active := false;
            SQL.Clear;
            SQL.Add('update tab_usuario set token_push = :token_push');
            SQL.Add('where cod_usuario = :cod_usuario');
            SQL.Add('returning cod_usuario');

            ParamByName('token_push').Value := token_push;
            ParamByName('cod_usuario').Value := cod_usuario;

            Active := true;
        end;

        Result := qry.ToJSONObject;

    finally
        FreeAndNil(qry);
    end;
end;

function TDmGlobal.EditarUsuario(cod_usuario: integer; nome, email: string): TJsonObject;
var
    qry: TFDQuery;
begin
    if (nome = '') or (email = '') then
        raise Exception.Create('Informe o nome e o e-mail do usuário');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        with qry do
        begin
            // Validacao do email...
            Active := false;
            SQL.Clear;
            SQL.Add('select cod_usuario from tab_usuario');
            SQL.Add('where email = :email and cod_usuario <> :cod_usuario');
            ParamByName('email').Value := email;
            ParamByName('cod_usuario').Value := cod_usuario;
            Active := true;

            if RecordCount > 0 then
                raise Exception.Create('Esse e-mail já está em uso por outra conta de usuário');

            Active := false;
            SQL.Clear;
            SQL.Add('update tab_usuario set nome = :nome, email=:email');
            SQL.Add('where cod_usuario = :cod_usuario');
            SQL.Add('returning cod_usuario');

            ParamByName('nome').Value := nome;
            ParamByName('email').Value := email;
            ParamByName('cod_usuario').Value := cod_usuario;

            Active := true;
        end;

        Result := qry.ToJSONObject;

    finally
        FreeAndNil(qry);
    end;
end;

function TDmGlobal.EditarSenha(cod_usuario: integer; senha: string): TJsonObject;
var
    qry: TFDQuery;
begin
    if (senha = '') then
        raise Exception.Create('Informe a senha do usuário');

    if (senha.Length < 5) then
        raise Exception.Create('A senha deve conter pelos menos 5 caracteres');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        with qry do
        begin
            Active := false;
            SQL.Clear;
            SQL.Add('update tab_usuario set senha = :senha');
            SQL.Add('where cod_usuario = :cod_usuario');
            SQL.Add('returning cod_usuario');

            ParamByName('senha').Value := SaltPassword(senha);
            ParamByName('cod_usuario').Value := cod_usuario;

            Active := true;
        end;

        Result := qry.ToJSONObject;

    finally
        FreeAndNil(qry);
    end;
end;

function TDmGlobal.ListarClientes(dt_ult_sincronizacao: string;
                                  pagina: integer): TJsonArray;
var
    qry: TFDQuery;
begin
    if (dt_ult_sincronizacao = '') then
        raise Exception.Create('Parâmetro dt_ult_sincronizacao não informado');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        with qry do
        begin
            Active := false;
            SQL.Clear;
            SQL.Add('select first :first skip :skip *');
            SQL.Add('from tab_cliente');
            SQL.Add('where data_ult_alteracao > :data_ult_alteracao');
            SQL.Add('order by cod_cliente');

            ParamByName('data_ult_alteracao').Value := dt_ult_sincronizacao;
            ParamByName('first').Value := QTD_REG_PAGINA_CLIENTE;
            ParamByName('skip').Value := (pagina * QTD_REG_PAGINA_CLIENTE) - QTD_REG_PAGINA_CLIENTE;

            Active := true;
        end;

        Result := qry.ToJSONArray;

    finally
        FreeAndNil(qry);
    end;
end;

function TDmGlobal.InserirEditarCliente(cod_usuario, cod_cliente_local: integer;
                                        cnpj_cpf, nome, fone, email, endereco, numero,
                                        complemento, bairro, cidade, uf, cep: string;
                                        latitude, longitude, limite_disponivel: double;
                                        cod_cliente_oficial: integer;
                                        dt_ult_sincronizacao: string): TJsonObject;
var
    qry: TFDQuery;
begin

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        with qry do
        begin
            Active := false;
            SQL.Clear;

            if cod_cliente_oficial = 0 then
            begin
                SQL.Add('insert into tab_cliente(cod_usuario, cnpj_cpf, nome, fone, email,');
                SQL.Add('endereco, numero, complemento, bairro, cidade, uf, ');
                SQL.Add('cep, latitude, longitude, limite_disponivel, data_ult_alteracao)');
                SQL.Add('values(:cod_usuario, :cnpj_cpf, :nome, :fone, :email,');
                SQL.Add(':endereco, :numero, :complemento, :bairro, :cidade, :uf, ');
                SQL.Add(':cep, :latitude, :longitude, :limite_disponivel, :data_ult_alteracao)');
                SQL.Add('returning cod_cliente as cod_cliente_oficial');

                ParamByName('cod_usuario').Value := cod_usuario;
            end
            else
            begin
                SQL.Add('update tab_cliente set cnpj_cpf=:cnpj_cpf, nome=:nome, fone=:fone, ');
                SQL.Add('email=:email, endereco=:endereco, numero=:numero, complemento=:complemento, ');
                SQL.Add('bairro=:bairro, cidade=:cidade, uf=:uf, cep=:cep, latitude=:latitude, ');
                SQL.Add('longitude=:longitude, limite_disponivel=:limite_disponivel, ');
                SQL.Add('data_ult_alteracao=:data_ult_alteracao ');
                SQL.Add('where cod_cliente = :cod_cliente ');
                SQL.Add('returning cod_cliente as cod_cliente_oficial');

                ParamByName('cod_cliente').Value := cod_cliente_oficial;
            end;

            ParamByName('cnpj_cpf').Value := cnpj_cpf;
            ParamByName('nome').Value := nome;
            ParamByName('fone').Value := fone;
            ParamByName('email').Value := email;
            ParamByName('endereco').Value := endereco;
            ParamByName('numero').Value := numero;
            ParamByName('complemento').Value := complemento;
            ParamByName('bairro').Value := bairro;
            ParamByName('cidade').Value := cidade;
            ParamByName('uf').Value :=  uf;
            ParamByName('cep').Value := cep;
            ParamByName('latitude').Value := latitude;
            ParamByName('longitude').Value := longitude;
            ParamByName('limite_disponivel').Value := limite_disponivel;
            ParamByName('data_ult_alteracao').Value := dt_ult_sincronizacao;
            Active := true;
        end;

        Result := qry.ToJSONObject;

    finally
        FreeAndNil(qry);
    end;
end;

function TDmGlobal.ListarProdutos(dt_ult_sincronizacao: string;
                                  pagina: integer): TJsonArray;
var
    qry: TFDQuery;
begin
    if (dt_ult_sincronizacao = '') then
        raise Exception.Create('Parâmetro dt_ult_sincronizacao não informado');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        with qry do
        begin
            Active := false;
            SQL.Clear;
            SQL.Add('select first :first skip :skip cod_produto, descricao,');
            SQL.Add('valor, qtd_estoque, cod_usuario, data_ult_alteracao');
            SQL.Add('from tab_produto');
            SQL.Add('where data_ult_alteracao > :data_ult_alteracao');
            SQL.Add('order by cod_produto');

            ParamByName('data_ult_alteracao').Value := dt_ult_sincronizacao;
            ParamByName('first').Value := QTD_REG_PAGINA_PRODUTO;
            ParamByName('skip').Value := (pagina * QTD_REG_PAGINA_PRODUTO) - QTD_REG_PAGINA_PRODUTO;

            Active := true;
        end;

        Result := qry.ToJSONArray;

    finally
        FreeAndNil(qry);
    end;
end;


function TDmGlobal.InserirEditarProduto(cod_usuario, cod_produto_local: integer;
                                        descricao: string;
                                        valor, qtd_estoque: double;
                                        cod_produto_oficial: integer;
                                        dt_ult_sincronizacao: string): TJsonObject;
var
    qry: TFDQuery;
begin

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        with qry do
        begin
            Active := false;
            SQL.Clear;

            if cod_produto_oficial = 0 then
            begin
                SQL.Add('insert into tab_produto(descricao, valor, qtd_estoque, cod_usuario, data_ult_alteracao)');
                SQL.Add('values(:descricao, :valor, :qtd_estoque, :cod_usuario, :data_ult_alteracao)');
                SQL.Add('returning cod_produto as cod_produto_oficial');

                ParamByName('cod_usuario').Value := cod_usuario;
            end
            else
            begin
                SQL.Add('update tab_produto set descricao=:descricao, valor=:valor,');
                SQL.Add('qtd_estoque=:qtd_estoque, data_ult_alteracao=:data_ult_alteracao ');
                SQL.Add('where cod_produto = :cod_produto ');
                SQL.Add('returning cod_produto as cod_produto_oficial');

                ParamByName('cod_produto').Value := cod_produto_oficial;
            end;

            ParamByName('descricao').Value := descricao;
            ParamByName('valor').Value := valor;
            ParamByName('qtd_estoque').Value := qtd_estoque;
            ParamByName('data_ult_alteracao').Value := dt_ult_sincronizacao;
            Active := true;
        end;

        Result := qry.ToJSONObject;

    finally
        FreeAndNil(qry);
    end;
end;

function TDmGlobal.ExcluirUsuario(cod_usuario: integer): TJsonObject;
var
    qry: TFDQuery;
begin
    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        try
            Conn.StartTransaction;

            with qry do
            begin
                Active := false;
                SQL.Clear;
                SQL.Add('update tab_usuario set ind_excluido = :ind_excluido, ');
                SQL.Add('email = :email, nome = :nome, token_push = :token_push, ');
                SQL.Add('plataforma = :plataforma ');
                SQL.Add('where cod_usuario = :cod_usuario');
                SQL.Add('returning cod_usuario as cod_usuario');

                ParamByName('ind_excluido').Value := 'S';
                ParamByName('email').Value := 'usuário excluido';
                ParamByName('nome').Value := 'usuário excluido';
                ParamByName('token_push').Value := '';
                ParamByName('plataforma').Value := '';
                ParamByName('cod_usuario').Value := cod_usuario;
                Active := true;

                Result := qry.ToJSONObject;


                Active := false;
                SQL.Clear;
                SQL.Add('delete from tab_notificacao where cod_usuario = :cod_usuario');
                ParamByName('cod_usuario').Value := cod_usuario;
                ExecSQL;
            end;

            Conn.Commit;

        except on ex:exception do
            begin
                Conn.Rollback;
                raise Exception.Create(ex.Message);
            end;
        end;

    finally
        FreeAndNil(qry);
    end;
end;

end.
