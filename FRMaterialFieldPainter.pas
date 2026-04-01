unit FRMaterialFieldPainter;

{$mode objfpc}{$H+}

{ TFRMaterialFieldPainter — Centralized rendering for Material Design 3 input fields.
  Gathers duplicate Paint routines from Edits, Combos, Memos, etc into a single place.
  License: LGPL v3
}

interface

uses
  Classes, SysUtils, Graphics, Controls, Types,
  BGRABitmap, BGRABitmapTypes,
  FRMaterial3Base, FRMaterialTheme;

type
  { Parâmetros visuais para renderização de campos MD3 }
  TFRMDFieldPaintParams = record
    Canvas: TCanvas;
    Rect: TRect;            { Bounds do componente (Self.ClientRect) }
    BgColor: TColor;        { Cor de fundo atual (Self.Color) }
    ParentBgColor: TColor;  { Cor de fundo do Parent }
    
    Variant: TFRMaterialVariant;
    BorderRadius: Integer;
    
    DecoColor: TColor;      { Cor do sublinhado/borda (foco ou validação) }
    HelperColor: TColor;    { Cor do texto de ajuda (HelperText) }
    DisabledColor: TColor;  { Cor inativa }
    
    IsFocused: Boolean;
    IsEnabled: Boolean;
    IsRequired: Boolean;
    
    { Dimensões do controle interno (TEdit, TMemo) para envolver com bordas }
    EditLeft, EditTop, EditWidth, EditHeight: Integer;
    
    { Limite direito máximo para estender o sublinhado/borda se houver botões }
    ActionRight: Integer;   
    
    { Margem inferior reservada para HelperText e Counter }
    BottomMargin: Integer;  
    
    HelperText: string;
    CharCounterText: string;
    PrefixText: string;
    SuffixText: string;
    
    EditFont: TFont;
    LabelFont: TFont;
    LabelRight: Integer;    { Posição para o "*" Required }
    LabelTop: Integer;
  end;

  TFRMaterialFieldPainter = class
  public
    class procedure DrawField(const P: TFRMDFieldPaintParams);
  end;

implementation

{ TFRMaterialFieldPainter }

class procedure TFRMaterialFieldPainter.DrawField(const P: TFRMDFieldPaintParams);
var
  LeftPos, RightPos, FieldTop, CR, DecoBottom: Integer;
  PrefixW: Integer;
  bmp: TBGRABitmap;
begin
  CR := P.BorderRadius * 2;
  DecoBottom := P.Rect.Bottom - P.BottomMargin;

  { Extensão horizontal do sublinhado/borda }
  if P.Variant = mvOutlined then
  begin
    LeftPos  := P.Rect.Left;
    RightPos := P.Rect.Right;
  end
  else if P.ParentBgColor = P.BgColor then
  begin
    LeftPos := P.EditLeft;
    if P.ActionRight > (P.EditLeft + P.EditWidth) then
      RightPos := P.ActionRight
    else
      RightPos := P.EditLeft + P.EditWidth;
  end
  else
  begin
    LeftPos  := P.Rect.Left;
    RightPos := P.Rect.Right;
  end;

  FieldTop := P.EditTop - 2;
  if FieldTop < 0 then FieldTop := 0;

  { Passo 1: Preenchimento do fundo }
  P.Canvas.Pen.Width   := 1;
  P.Canvas.Pen.Color   := P.BgColor;
  P.Canvas.Brush.Color := P.BgColor;
  
  if P.Variant = mvFilled then
  begin
    { MD3 spec: filled variant has top corners rounded, bottom corners square }
    bmp := TBGRABitmap.Create(P.Rect.Right, P.Rect.Bottom, BGRAPixelTransparent);
    try
      MD3FillTopRoundRect(bmp, P.Rect.Left, P.Rect.Top, P.Rect.Right - 1, DecoBottom - 1, CR, P.BgColor);
      bmp.Draw(P.Canvas, 0, 0, False);
    finally
      bmp.Free;
    end;
  end
  else
  begin
    P.Canvas.Rectangle(P.Rect);
  end;

  { Passo 2: Decoração do campo (Borda/Sublinhado) }
  P.Canvas.Pen.Color := P.DecoColor;

  case P.Variant of
    mvStandard, mvFilled:
    begin
      if P.IsFocused and P.IsEnabled then
      begin
        P.Canvas.Line(LeftPos, DecoBottom - 2, RightPos, DecoBottom - 2);
        P.Canvas.Line(LeftPos, DecoBottom - 1, RightPos, DecoBottom - 1);
      end else
        P.Canvas.Line(LeftPos, DecoBottom - 1, RightPos, DecoBottom - 1);
    end;
    mvOutlined:
    begin
      P.Canvas.Brush.Style := bsClear;
      if P.IsFocused and P.IsEnabled then
        P.Canvas.Pen.Width := 2
      else
        P.Canvas.Pen.Width := 1;
        
      if CR > 0 then
        P.Canvas.RoundRect(LeftPos, FieldTop, RightPos, DecoBottom - 1, CR, CR)
      else
        P.Canvas.Rectangle(LeftPos, FieldTop, RightPos, DecoBottom - 1);
        
      P.Canvas.Pen.Width   := 1;
      P.Canvas.Brush.Style := bsSolid;
    end;
  end;

  { Passo 3: Required asterisk ("*") }
  if P.IsRequired then
  begin
    P.Canvas.Font.Assign(P.LabelFont);
    P.Canvas.Font.Color := P.DecoColor; { Original usa FInvalidColor fixo, vamos parametrizar? }
    P.Canvas.Brush.Style := bsClear;
    P.Canvas.TextOut(P.LabelRight + 2, P.LabelTop, ' *');
    P.Canvas.Brush.Style := bsSolid;
  end;

  { Passo 4: Prefix / Suffix }
  if P.PrefixText <> '' then
  begin
    P.Canvas.Font.Assign(P.EditFont);
    P.Canvas.Font.Color := P.DisabledColor;
    P.Canvas.Brush.Style := bsClear;
    PrefixW := P.Canvas.TextWidth(P.PrefixText + ' ');
    P.Canvas.TextOut(P.EditLeft - PrefixW, P.EditTop + (P.EditHeight - P.Canvas.TextHeight(P.PrefixText)) div 2, P.PrefixText);
    P.Canvas.Brush.Style := bsSolid;
  end;

  if P.SuffixText <> '' then
  begin
    P.Canvas.Font.Assign(P.EditFont);
    P.Canvas.Font.Color := P.DisabledColor;
    P.Canvas.Brush.Style := bsClear;
    P.Canvas.TextOut(P.EditLeft + P.EditWidth + 2,
      P.EditTop + (P.EditHeight - P.Canvas.TextHeight(P.SuffixText)) div 2, P.SuffixText);
    P.Canvas.Brush.Style := bsSolid;
  end;

  { Passo 5: Helper text / Error text (abaixo da decoração) }
  if P.BottomMargin > 0 then
  begin
    P.Canvas.Font.Assign(P.EditFont); // Volta ao fonte padrão herdado
    P.Canvas.Font.Size := P.EditFont.Size - 1;
    if P.Canvas.Font.Size < 7 then P.Canvas.Font.Size := 7;
    P.Canvas.Brush.Style := bsClear;

    if P.HelperText <> '' then
    begin
      P.Canvas.Font.Color := P.HelperColor;
      P.Canvas.TextOut(LeftPos + 4, DecoBottom + 2, P.HelperText);
    end;

    { Contador de caracteres }
    if P.CharCounterText <> '' then
    begin
      P.Canvas.Font.Color := P.DisabledColor;
      P.Canvas.TextOut(RightPos - P.Canvas.TextWidth(P.CharCounterText) - 4, DecoBottom + 2, P.CharCounterText);
    end;

    P.Canvas.Brush.Style := bsSolid;
  end;
end;

end.
