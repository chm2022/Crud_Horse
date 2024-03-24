unit Controllers.Usuario;

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
procedure InserirUsuario(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure Login(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure Push(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure EditarUsuario(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure ExcluirUsuario(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure EditarSenha(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure ObterDataServidor(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation


procedure RegistrarRotas;
begin
    THorse.Post('/usuarios', InserirUsuario);
    THorse.Post('/usuarios/login', Login);

    THorse.AddCallback(HorseJWT(Controllers.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
          .Put('/usuarios', EditarUsuario);

    THorse.AddCallback(HorseJWT(Controllers.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
          .Delete('/usuarios/:cod_usuario', ExcluirUsuario);
end;

procedure InserirUsuario(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    DmGlobal: TDmGlobal;
    nome, email, senha: string;
    cod_usuario: integer;
    body, json_ret: TJsonObject;
begin
    try
        try
            DmGlobal := TDmGlobal.Create(Nil);

            body := Req.Body<TJsonObject>;
            nome := body.GetValue<string>('nome', '');
            email := body.GetValue<string>('email', '');
            senha := body.GetValue<string>('senha', '');

            json_ret := DmGlobal.InserirUsuario(nome, email, senha);

            cod_usuario := json_ret.GetValue<integer>('cod_usuario', 0);

            json_ret.AddPair('nome', nome);
            json_ret.AddPair('email', email);

            // Gerar o token contendo o cod_usuario....
            json_ret.AddPair('token', Criar_Token(cod_usuario));
            //------------------------------------------

            Res.Send<TJsonObject>(json_ret).Status(201);

        except on ex:exception do
            Res.Send(ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure Login(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    DmGlobal: TDmGlobal;
    email, senha: string;
    cod_usuario: integer;
    body, json_ret: TJsonObject;
begin
    try
        try
            DmGlobal := TDmGlobal.Create(Nil);

            body := Req.Body<TJsonObject>;
            email := body.GetValue<string>('email', '');
            senha := body.GetValue<string>('senha', '');

            json_ret := DmGlobal.Login(email, senha);

            if json_ret.Size = 0 then
                Res.Send('E-mail ou senha inválida.').Status(401)
            else
            begin
                cod_usuario := json_ret.GetValue<integer>('cod_usuario', 0);

                // Gerar o token contendo o cod_usuario....
                json_ret.AddPair('token', Criar_Token(cod_usuario));
                //------------------------------------------

                Res.Send<TJsonObject>(json_ret).Status(200);
            end;

        except on ex:exception do
            Res.Send(ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure EditarUsuario(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    DmGlobal: TDmGlobal;
    nome, email: string;
    cod_usuario: integer;
    body, json_ret: TJsonObject;
begin
    try
        try
            DmGlobal := TDmGlobal.Create(Nil);

            cod_usuario := Get_Usuario_Request(Req);

            body := Req.Body<TJsonObject>;
            nome := body.GetValue<string>('nome', '');
            email := body.GetValue<string>('email', '');

            json_ret := DmGlobal.EditarUsuario(cod_usuario, nome, email);

            Res.Send<TJsonObject>(json_ret).Status(200);

        except on ex:exception do
            Res.Send(ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure ExcluirUsuario(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    DmGlobal: TDmGlobal;
    cod_usuario, cod_usuario_param: integer;
    json_ret: TJsonObject;
begin
    try
        try
            DmGlobal := TDmGlobal.Create(Nil);

            cod_usuario := Get_Usuario_Request(Req);

            try
                cod_usuario_param := Req.Params.Items['cod_usuario'].ToInteger;
            except
                cod_usuario_param := 0;
            end;

            if cod_usuario <> cod_usuario_param then
                raise Exception.Create('Operação não permitida');

            json_ret := DmGlobal.ExcluirUsuario(cod_usuario);

            Res.Send<TJsonObject>(json_ret).Status(200);

        except on ex:exception do
            Res.Send(ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure EditarSenha(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    DmGlobal: TDmGlobal;
    senha: string;
    cod_usuario: integer;
    body, json_ret: TJsonObject;
begin
    try
        try
            DmGlobal := TDmGlobal.Create(Nil);

            cod_usuario := Get_Usuario_Request(Req);

            body := Req.Body<TJsonObject>;
            senha := body.GetValue<string>('senha', '');

            json_ret := DmGlobal.EditarSenha(cod_usuario, senha);

            Res.Send<TJsonObject>(json_ret).Status(200);

        except on ex:exception do
            Res.Send(ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;

end.
