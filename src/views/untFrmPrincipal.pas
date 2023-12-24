unit untFrmPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Effects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Ani, JSON,
  FMX.Edit, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, Loading, IPPeerCommon,
  IPPeerServer, IPPeerClient, Winapi.Windows, System.RegularExpressions,
  untFrmAviso, ApiConsultaCNPJ;

type
  TFrmConsultaCNPJ = class(TForm)
    recConsulta, recInformacoes, recAtividade, btnConsultar: TRectangle;
    lblConsulta, lblInfoGeral, lblCNPJ, lblAtividade: TLabel;
    lblTipo, lblRazao, lblFantasia, lblCidadeUf: TLabel;
    lblCep, lblContatos, lblSituacao, lblButton, lblLogradouro: TLabel;
    edtCnpj, edtTipo, edtRazaoSocial, edtNomeFantasia, edtCidade: TEdit;
    edtCep, edtLogradouro, edtContatos: TEdit;
    meAtividade: TMemo;
    Loading: TLoading;
    procedure btnConsultarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FApiConsultaCNPJ:TConsultaCNPJ;
    procedure pShowMessageForm(AstrMessage:string);
    procedure pAtribuirValores(const AstrValor: string; const AControl: TObject);
    procedure pAtribuirSituacao(const AstrValor: string);
    function fCreateThread(AstrCNPJ:string): TThread;
    function fTiraCaracteresCNPJ(AstrCNPJ: String): String;
    function fValidarCNPJ(AstrCNPJ: string): Boolean;
    procedure pAtualizaCampos;
    procedure pFinalizaConsulta;
  public
    { Public declarations }
  end;

var
  FrmConsultaCNPJ: TFrmConsultaCNPJ;

implementation

{$R *.fmx}


procedure TFrmConsultaCNPJ.pAtribuirValores(const AstrValor: string; const AControl: TObject);
begin
  if AstrValor = '' then
  begin
    if AControl is TEdit then
      TEdit(AControl).Text := 'N/A'
  end
  else
    TEdit(AControl).Text := AstrValor;
end;

procedure TFrmConsultaCNPJ.pAtualizaCampos;
var
  LJSONValue:TJSONValue;
begin
  pAtribuirValores(FApiConsultaCNPJ.fRetResp('tipo'), edtTipo);
  pAtribuirValores(FApiConsultaCNPJ.fRetResp('nome'), edtRazaoSocial);
  pAtribuirValores(FApiConsultaCNPJ.fRetResp('fantasia'), edtNomeFantasia);
  pAtribuirValores(FApiConsultaCNPJ.fRetResp('municipio') +
    ' / ' + FApiConsultaCNPJ.fRetResp('uf'), edtCidade);
  pAtribuirValores(FApiConsultaCNPJ.fRetResp('cep'), edtCep);
  pAtribuirValores(FApiConsultaCNPJ.fRetResp('logradouro'), edtLogradouro);
  pAtribuirSituacao(FApiConsultaCNPJ.fRetResp('situacao'));

  if (FApiConsultaCNPJ.fRetResp('telefone') = '') and
        (FApiConsultaCNPJ.fRetResp('email') = '') then
    pAtribuirValores('N/A', edtContatos)
  else
    pAtribuirValores(FApiConsultaCNPJ.fRetResp('email') + ' / ' +
      FApiConsultaCNPJ.fRetResp('telefone'), edtContatos);

  {Adiciona atividade da empresa no TMemo}
  meAtividade.Lines.Clear;
  for LJSONValue in FApiConsultaCNPJ.fRetRespList('atividade_principal') do
  begin
    meAtividade.Lines.Add(
      Format('Código = %s | Descrição  = %s',
          [
            (LJSONValue as TJSONObject).Values['code'].Value,
            (LJSONValue as TJSONObject).Values['text'].Value
          ]
        )
      );
  end;
end;

procedure TFrmConsultaCNPJ.pFinalizaConsulta;
begin
  Self.Invalidate;
  Loading.Stop;
  Loading.Visible:=False;
  btnConsultar.Visible:=True;
  lblButton.Visible:= True;
end;

procedure TFrmConsultaCNPJ.pAtribuirSituacao(const AstrValor: string);
begin
  if AstrValor = '' then
    lblSituacao.Visible := False
  else
  begin
    lblSituacao.Text := AstrValor;
    lblSituacao.Visible := True;
  end;
end;

function TFrmConsultaCNPJ.fCreateThread(AstrCNPJ:string): TThread;
begin
  Result := TThread.CreateAnonymousThread(procedure
  begin
    {consultando cnpj na receita}
    try
      FApiConsultaCNPJ.pConsultarCNPJ(AstrCNPJ);
    except
      on E:Exception do
      begin
        TThread.Synchronize(nil,
        procedure
        begin
          pFinalizaConsulta;
          pShowMessageForm(E.Message);
        end);
      end;
    end;
    {atribuindo valores do retorno aos respequitivos campos}
    pAtualizaCampos;

    TThread.Synchronize(nil,
    procedure
    begin
      pFinalizaConsulta;
    end);
  end)
end;

procedure TFrmConsultaCNPJ.FormCreate(Sender: TObject);
begin
  FApiConsultaCNPJ := TConsultaCNPJ.Create;
end;

procedure TFrmConsultaCNPJ.FormDestroy(Sender: TObject);
begin
  FApiConsultaCNPJ.Free;
end;

function TFrmConsultaCNPJ.fValidarCNPJ(AstrCNPJ: string): Boolean;
var
  Regex: TRegEx;
begin
  {define estrutura a ser verificada}
  Regex := TRegEx.Create('^(\d{2}\.?\d{3}\.?\d{3}/?\d{4}-?\d{2})$');
  {verifica se a estrutura é correspondente}
  Result := Regex.IsMatch(AstrCNPJ);
end;

procedure TFrmConsultaCNPJ.btnConsultarClick(Sender: TObject);
var
  LCNPJ:string;
begin
  LCNPJ:=edtCnpj.Text;
  if fValidarCNPJ(LCNPJ) then
  begin
    btnConsultar.Visible := False;
    lblButton.Visible :=    False;
    Loading.Visible :=      True;

    Loading.Start;

    {iniciando thread de consulta na API}
    try
      fCreateThread(fTiraCaracteresCNPJ(LCNPJ)).Start;
    except
      on E:Exception do
      begin
        pShowMessageForm(E.Message);
      end;
    end;
  end
  else
    pShowMessageForm('CNPJ Invalido!');
    edtCnpj.Text:='';
end;

procedure TFrmConsultaCNPJ.pShowMessageForm(AstrMessage: string);
var
  FrmAviso:TFrmAviso;
begin
  Application.CreateForm(TFrmAviso, FrmAviso);
  FrmAviso.lblMessage.Text := AstrMessage;
  FrmAviso.ShowModal;
  FreeAndNil(FrmAviso);
end;

function TFrmConsultaCNPJ.fTiraCaracteresCNPJ(AstrCNPJ: String): String;
begin
  AstrCNPJ := StringReplace(AstrCNPJ, '.', '', [rfReplaceAll]);
  AstrCNPJ := StringReplace(AstrCNPJ, '-', '', [rfReplaceAll]);
  Result := StringReplace(AstrCNPJ, '/', '', [rfReplaceAll]);
end;


end.
