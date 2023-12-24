unit untFrmAviso;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects;

type
  TFrmAviso = class(TForm)
    recMessage: TRectangle;
    lblMessage: TLabel;
    lblAviso: TLabel;
    btnOk: TRectangle;
    lblButton: TLabel;
    procedure btnOkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmAviso: TFrmAviso;

implementation

{$R *.fmx}

procedure TFrmAviso.btnOkClick(Sender: TObject);
begin
  Self.Close;
end;

end.
