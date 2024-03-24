unit Controllers.Produto;

interface

uses Horse,
     Horse.Jhonson,
     Horse.CORS,
     Horse.Upload,
     System.SysUtils,
     DataModule.Global,
     System.JSON,
     Controllers.Auth,
     Horse.JWT,
     System.Classes,
     FMX.Graphics;

procedure RegistrarRotas;
procedure ListarProdutos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure InserirEditarProduto(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

procedure RegistrarRotas;
begin
    THorse.AddCallback(HorseJWT(Controllers.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
          .Get('/produtos/sincronizacao', ListarProdutos);

    THorse.AddCallback(HorseJWT(Controllers.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
          .Post('/produtos/sincronizacao', InserirEditarProduto);

end;

procedure ListarProdutos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
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

            Res.Send<TJsonArray>(DmGlobal.ListarProdutos(dt_ult_sincronizacao, pagina)).Status(200);

        except on ex:exception do
            Res.Send(ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure InserirEditarProduto(Req: THorseRequest; Res: THorseResponse; Next: TProc);
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


            json_ret := DmGlobal.InserirEditarProduto(cod_usuario,
                                    body.GetValue<integer>('cod_produto_local', 0),
                                    body.GetValue<string>('descricao', ''),
                                    body.GetValue<double>('valor', 0),
                                    body.GetValue<double>('qtd_estoque', 0),
                                    body.GetValue<integer>('cod_produto_oficial', 0),
                                    body.GetValue<string>('dt_ult_sincronizacao', '')
                                    );

            json_ret.AddPair('cod_produto_local', TJsonNumber.Create(body.GetValue<integer>('cod_produto_local', 0)));

            Res.Send<TJsonObject>(json_ret).Status(200);

        except on ex:exception do
            Res.Send(ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;

end.
