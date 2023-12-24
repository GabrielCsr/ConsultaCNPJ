unit ApiConsultaCNPJIntf;

interface

uses
  System.JSON;

type
  IConsultaCNPJ = interface
    ['{FAE99D05-9FE7-4058-B4C3-AC7A1C3A7C6E}']
    procedure pConsultarCNPJ(const AstrCNPJ: string);
    procedure pIniciarConsulta(const AstrCNPJ: string);
    function fRetResp(const AstrName: string): String;
    function fRetRespList(const AstrList: string): TJSONArray;
  end;

implementation

end.
