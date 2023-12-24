program ConsultaCNPJ;

uses
  System.StartUpCopy,
  FMX.Forms,
  ApiConsultaCNPJ in 'src\ApiConsultaCNPJ.pas',
  ApiConsultaCNPJIntf in 'src\ApiConsultaCNPJIntf.pas',
  Loading in 'src\Loading.pas',
  untFrmAviso in 'src\views\untFrmAviso.pas' {FrmAviso},
  untFrmPrincipal in 'src\views\untFrmPrincipal.pas' {FrmConsultaCNPJ};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmConsultaCNPJ, FrmConsultaCNPJ);
  Application.Run;
end.
