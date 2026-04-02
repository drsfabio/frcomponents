unit FRMaterialInternalEdits;

{$mode objfpc}{$H+}

{ Subclasses internas de controles de edição que suprimem a borda nativa
  do Windows (WS_EX_CLIENTEDGE) para permitir que o componente Material
  Design pinte sua própria decoração sem interferência do tema do SO.

  Estas classes devem ser usadas APENAS internamente pelos componentes
  FRMaterial*Edit. Não são registradas na paleta de componentes. }

interface

uses
  Classes, Controls, StdCtrls, MaskEdit, Spin, ComCtrls, LCLType;

type

  { TEdit sem borda nativa }
  TFRInternalEdit = class(TEdit)
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  end;

  { TMaskEdit sem borda nativa }
  TFRInternalMaskEdit = class(TMaskEdit)
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  end;

  { TMemo sem borda nativa }
  TFRInternalMemo = class(TMemo)
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  end;

  { TComboBox sem borda nativa }
  TFRInternalComboBox = class(TComboBox)
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  end;

  { TSpinEdit sem borda nativa }
  TFRInternalSpinEdit = class(TSpinEdit)
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  end;

implementation

const
  { Window Extended Styles — definidos localmente para não depender da unit Windows }
  FR_WS_EX_CLIENTEDGE = $00000200;

{ Remove WS_EX_CLIENTEDGE do estilo estendido da janela.
  Isso impede o Windows de desenhar a borda 3D/tema de foco
  sobre o controle, deixando toda a decoração por conta dos
  componentes Material Design. }

procedure TFRInternalEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle and not FR_WS_EX_CLIENTEDGE;
end;

procedure TFRInternalMaskEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle and not FR_WS_EX_CLIENTEDGE;
end;

procedure TFRInternalMemo.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle and not FR_WS_EX_CLIENTEDGE;
end;

procedure TFRInternalComboBox.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle and not FR_WS_EX_CLIENTEDGE;
end;

procedure TFRInternalSpinEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle and not FR_WS_EX_CLIENTEDGE;
end;

end.
