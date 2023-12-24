unit ApiConsultaCNPJ;

interface

uses
  System.SysUtils, REST.Client, REST.Types, System.JSON, ApiConsultaCNPJIntf,
  FMX.Dialogs;

type
  TConsultaCNPJ = class(TInterfacedObject, IConsultaCNPJ)
  private
    FRestClient:   TRESTClient;
    FRestRequest:  TRESTRequest;
    FRestResponse: TRESTResponse;
    FJSONObj:      TJSONObject;
    FUltimoCNPJ:   String;
    procedure pIniciarConsulta(const AstrCNPJ: string);
  public
    constructor Create;
    destructor Destroy; override;
    procedure pConsultarCNPJ(const AstrCNPJ: string);
    function fRetResp(const AstrName: string): String;
    function fRetRespList(const AstrList: string): TJSONArray;
  end;

const
  URLReceitaWS = 'https://receitaws.com.br/v1/cnpj/%s';

implementation

uses
  UITypes, System.Classes;

{ TConsultaCNPJ }

constructor TConsultaCNPJ.Create;
begin
  {inicializando objetos da classe}
  FRestClient:=  TRESTClient.Create(nil);
  FRestRequest:= TRESTRequest.Create(nil);
  FRestResponse:=TRESTResponse.Create(nil);
end;

destructor TConsultaCNPJ.Destroy;
begin
  {destruindo objetos utilizados}
  FreeAndNil(FRestClient);
  FreeAndNil(FRestRequest);
  FreeAndNil(FRestResponse);
  inherited;
end;

procedure TConsultaCNPJ.pConsultarCNPJ(const AstrCNPJ: string);
var
  LButtonSelected: TModalResult;
begin
  {verificando se o CNPJ armazenado � o mesmo da nova solicita��o}
  if FUltimoCNPJ = AstrCNPJ then
  begin
    LButtonSelected := MessageDlg(
      'CNPJ Consultado anteriormente, deseja consultar novamente?'+
      ' Obs: A API tem um n�mero limite de requisi��es por minuto, ' +
      'pode ser necess�rio aguardar para fazer a solicita��o novamente.',
      TMsgDlgType.mtConfirmation,
      [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
      0
    );

    if LButtonSelected = mrYes then
    begin
      try 
        pIniciarConsulta(AstrCNPJ);
      except
        on E:Exception do
        begin
          raise Exception.Create(E.Message);
        end;
      end;
    end
    else
    begin
      exit;
    end;
  end
  else
  begin
    // Se o CNPJ for diferente, realiza a consulta diretamente
    try 
      pIniciarConsulta(AstrCNPJ);
    except
      on E:Exception do
      begin
        raise Exception.Create(E.Message);
      end;
    end;
  end;
end;

function TConsultaCNPJ.fRetResp(const AstrName: string): String;
begin
  Result := FJSONObj.Values[AstrName].Value;
end;


function TConsultaCNPJ.fRetRespList(const AstrList: string): TJSONArray;
begin
  Result:= FJSONObj.Values[AstrList] as TJSONArray;
end;

  procedure TConsultaCNPJ.pIniciarConsulta(const AstrCNPJ: string);
  var
    LStatusValue:String;
  begin
    {definindo URL requisi��o}
    FRestClient.BaseURL:= Format(URLReceitaWS,[AstrCNPJ]);
    FRestRequest.Client := FRestClient;
    FRestRequest.Method := rmGet;
    {executando requisi��o}
    FRestRequest.Execute;

    {tratando status do retorno}
    if FRestRequest.Response.StatusCode = 429 then
      raise Exception.Create('Voc� esta realizando muitas consultas. '+
                            'Aguarde um instante e tente novamente');

    if FRestRequest.Response.StatusCode = 504 then
      raise Exception.Create('TimeOut');


    FJSONObj := FRestRequest.Response.JSONValue as TJSONObject;

    {Tratando possiveis exce��es}
    if FJSONObj.TryGetValue('status', LStatusValue) then
    begin
      if LStatusValue = 'ERROR' then
        raise Exception.Create(FJSONObj.Values['message'].Value);
    end;

    FUltimoCNPJ:=AstrCNPJ;
  end;

end.
