unit DataModule.Usuario;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, RESTRequest4D, System.JSON;

type
  TDmUsuario = class(TDataModule)
    qryUsuario: TFDQuery;
    qryConsUsuario: TFDQuery;
    TabUsuario: TFDMemTable;
  private
    { Private declarations }
  public
    procedure EditarUsuario(nome, email: string);
    procedure ListarUsuarios;
    procedure InserirUsuario(cod_usuario: integer;
                                    nome, email, senha, token_jwt: string);
    procedure ExcluirUsuario;
    procedure EditarSenha(senha: string);
    procedure Logout;
    procedure DesativarOnboarding;
    procedure LoginWeb(email, senha: string);
    procedure NovaContaWeb(nome, email, senha: string);
    procedure EditarUsuarioWeb(nome, email: string);
    procedure EditarSenhaWeb(senha: string);
    function ObterDataServidor: string;
    procedure ExcluirContaWeb;
  end;

var
  DmUsuario: TDmUsuario;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

uses DataModule.Global;

{$R *.dfm}

procedure TDmUsuario.ListarUsuarios;
begin
    qryConsUsuario.Active := false;
    qryConsUsuario.SQL.Clear;
    qryConsUsuario.SQL.Add('select * from tab_usuario');
    qryConsUsuario.active := true;
end;

procedure TDmUsuario.InserirUsuario(cod_usuario: integer;
                                    nome, email, senha, token_jwt: string);
begin
    qryUsuario.Active := false;
    qryUsuario.SQL.Clear;
    qryUsuario.SQL.Add('insert into tab_usuario(cod_usuario, nome, email, senha, token_jwt, ind_login, ind_onboarding)');
    qryUsuario.SQL.Add('values(:cod_usuario, :nome, :email, :senha, :token_jwt, :ind_login, :ind_onboarding)');

    qryUsuario.ParamByName('cod_usuario').Value := cod_usuario;
    qryUsuario.ParamByName('nome').Value := nome;
    qryUsuario.ParamByName('email').Value := email;
    qryUsuario.ParamByName('senha').Value := senha;
    qryUsuario.ParamByName('token_jwt').Value := token_jwt;
    qryUsuario.ParamByName('ind_login').Value := 'S';
    qryUsuario.ParamByName('ind_onboarding').Value := 'N';

    qryUsuario.ExecSQL;
end;

procedure TDmUsuario.EditarUsuario(nome, email: string);
begin
    qryUsuario.Active := false;
    qryUsuario.SQL.Clear;
    qryUsuario.SQL.Add('update tab_usuario set nome=:nome, email=:email');

    qryUsuario.ParamByName('nome').Value := nome;
    qryUsuario.ParamByName('email').Value := email;

    qryUsuario.ExecSQL;
end;

procedure TDmUsuario.ExcluirUsuario;
begin
    qryUsuario.Active := false;
    qryUsuario.SQL.Clear;
    qryUsuario.SQL.Add('delete from tab_usuario');
    qryUsuario.ExecSQL;
end;

procedure TDmUsuario.EditarSenha(senha: string);
begin
    qryUsuario.Active := false;
    qryUsuario.SQL.Clear;
    qryUsuario.SQL.Add('update tab_usuario set senha=:senha');

    qryUsuario.ParamByName('senha').Value := senha;

    qryUsuario.ExecSQL;
end;

procedure TDmUsuario.Logout;
begin
    qryUsuario.Active := false;
    qryUsuario.SQL.Clear;
    qryUsuario.SQL.Add('update tab_usuario set ind_login=:ind_login, ind_onboarding=:ind_onboarding');
    qryUsuario.ParamByName('ind_login').Value := 'N';
    qryUsuario.ParamByName('ind_onboarding').Value := 'N';
    qryUsuario.ExecSQL;

    qryUsuario.Active := false;
    qryUsuario.SQL.Clear;
    qryUsuario.SQL.Add('delete from tab_pedido_item');
    qryUsuario.ExecSQL;

    qryUsuario.Active := false;
    qryUsuario.SQL.Clear;
    qryUsuario.SQL.Add('delete from tab_pedido');
    qryUsuario.ExecSQL;

    qryUsuario.Active := false;
    qryUsuario.SQL.Clear;
    qryUsuario.SQL.Add('delete from tab_notificacao');
    qryUsuario.ExecSQL;

    qryUsuario.Active := false;
    qryUsuario.SQL.Clear;
    qryUsuario.SQL.Add('delete from tab_produto');
    qryUsuario.ExecSQL;

    qryUsuario.Active := false;
    qryUsuario.SQL.Clear;
    qryUsuario.SQL.Add('delete from tab_cliente');
    qryUsuario.ExecSQL;

    qryUsuario.Active := false;
    qryUsuario.SQL.Clear;
    qryUsuario.SQL.Add('delete from tab_cond_pagto');
    qryUsuario.ExecSQL;

    qryUsuario.Active := false;
    qryUsuario.SQL.Clear;
    qryUsuario.SQL.Add('delete from tab_config where campo <> ''VERSAO'' ');
    qryUsuario.ExecSQL;
end;

end.
