unit Controllers.Cliente;

interface

uses Horse,
     Horse.Jhonson,
     Horse.CORS,
     System.SysUtils,
     DataModule.Global,
     System.JSON,
     Controllers.Auth,
     Horse.JWT;

procedure RegistrarRotas;
procedure ListarClientes(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure InserirEditarCliente(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

procedure RegistrarRotas;
begin
    THorse.AddCallback(HorseJWT(Controllers.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
          .Get('/clientes/sincronizacao', ListarClientes);

    THorse.AddCallback(HorseJWT(Controllers.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
          .Post('/clientes/sincronizacao', InserirEditarCliente);
end;

procedure ListarClientes(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    DmGlobal: TDmGlobal;
    dt_ult_sincronizacao: string;
    pagina: integer;
begin
    try
        try
            DmGlobal := TDmGlobal.Create(Nil);

            try
                dt_ult_sincronizacao := Req.Query['dt_ult_sincronizacao'];
            except
                dt_ult_sincronizacao := '';
            end;

            try
                pagina := Req.Query['pagina'].ToInteger;
            except
                pagina := 1;
            end;

            Res.Send<TJsonArray>(DmGlobal.ListarClientes(dt_ult_sincronizacao, pagina)).Status(200);

        except on ex:exception do
            Res.Send(ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure InserirEditarCliente(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    DmGlobal: TDmGlobal;
    cod_usuario: integer;
    body, json_ret: TJsonObject;
begin
    try
        try
            DmGlobal := TDmGlobal.Create(Nil);

            cod_usuario := Get_Usuario_Request(Req);
            body := Req.Body<TJsonObject>;

            json_ret := DmGlobal.InserirEditarCliente(cod_usuario,
                                    body.GetValue<integer>('cod_cliente_local', 0),
                                    body.GetValue<string>('cnpj_cpf', ''),
                                    body.GetValue<string>('nome', ''),
                                    body.GetValue<string>('fone', ''),
                                    body.GetValue<string>('email', ''),
                                    body.GetValue<string>('endereco', ''),
                                    body.GetValue<string>('numero', ''),
                                    body.GetValue<string>('complemento', ''),
                                    body.GetValue<string>('bairro', ''),
                                    body.GetValue<string>('cidade', ''),
                                    body.GetValue<string>('uf', ''),
                                    body.GetValue<string>('cep', ''),
                                    body.GetValue<double>('latitude', 0),
                                    body.GetValue<double>('longitude', 0),
                                    body.GetValue<double>('limite_disponivel', 0),
                                    body.GetValue<integer>('cod_cliente_oficial', 0),
                                    body.GetValue<string>('dt_ult_sincronizacao', '')
                                    );

            json_ret.AddPair('cod_cliente_local', TJsonNumber.Create(body.GetValue<integer>('cod_cliente_local', 0)));
            Res.Send<TJsonObject>(json_ret).Status(200);

        except on ex:exception do
            Res.Send(ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;

end.
