unit Controllers.Auth;

interface

uses Horse,
     Horse.JWT,
     JOSE.Core.JWT,
     JOSE.Types.JSON,
     JOSE.Core.Builder,
     System.JSON,
     System.SysUtils;

const
    SECRET = 'CH!!#@123';

type
  TMyClaims = class(TJWTClaims)
  private
    function GetCodUsuario: integer;
    procedure SetCodUsuario(const Value: integer);
  public
    property COD_USUARIO: integer read GetCodUsuario write SetCodUsuario;
  end;

function Criar_Token(cod_usuario: integer): string;
function Get_Usuario_Request(Req: THorseRequest): integer;

implementation

function Criar_Token(cod_usuario: integer): string;
var
    jwt: TJWT;
    claims: TMyClaims;
begin
    try
        jwt := TJWT.Create;
        claims := TMyClaims(jwt.Claims);

        try
            claims.COD_USUARIO := cod_usuario;

            Result := TJOSE.SHA256CompactToken(SECRET, jwt);
        except
            Result := '';
        end;

    finally
        FreeAndNil(jwt);
    end;
end;

function Get_Usuario_Request(Req: THorseRequest): integer;
var
    claims: TMyClaims;
begin
    claims := Req.Session<TMyClaims>;
    Result := claims.COD_USUARIO;
end;

function TMyClaims.GetCodUsuario: integer;
begin
    Result := FJSON.GetValue<integer>('id', 0);
end;

procedure TMyClaims.SetCodUsuario(const Value: integer);
begin
    TJSONUtils.SetJSONValueFrom<integer>('id', Value, FJSON);
end;

end.
