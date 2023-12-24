unit Loading;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation, FMX.Ani;

type
  TLoading = class(TCircle)
  private
    { Private declarations }
    FAnimation:TFloatAnimation;
    FInterpolation:TInterpolationType;
    procedure SetInterpolationType(Value:TInterpolationType);
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  published
    { Published declarations }
    property Interpolation: TInterpolationType read FInterpolation write SetInterpolationType
        default TInterpolationType.Circular;
    procedure Start;
    procedure Stop;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('GaComponents', [TLoading]);
end;

{ TLoading }

constructor TLoading.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  //criando circulo
  Self.Width := 20;
  Self.Height := 20;
  Self.Fill.Kind := TBrushKind.None;
  Self.Stroke.Dash := TStrokeDash.Dot;
  Self.Stroke.Thickness := 3;
  Self.Stroke.Cap := TStrokeCap.Round;
  Self.Stroke.Color := TAlphaColorRec.Black;

  //criando animação do circulo
  FAnimation := TFloatAnimation.Create(Self);
  FAnimation.Parent := Self;

  FAnimation.PropertyName := 'RotationAngle';
  FAnimation.StartValue := 0;
  FAnimation.StopValue := 360;
  FAnimation.Duration := 2;
  FAnimation.Loop := True;
end;

procedure TLoading.SetInterpolationType(Value: TInterpolationType);
begin
  FInterpolation:=Value;
  FAnimation.Interpolation:=FInterpolation;
end;

procedure TLoading.Start;
begin
  FAnimation.Enabled:= True;
  FAnimation.Start;
end;

procedure TLoading.Stop;
begin
  FAnimation.Enabled:= False;
  FAnimation.Stop;
end;

end.
