unit FRMaterialFieldPainter;

{$mode objfpc}{$H+}

{ TFRMaterialFieldPainter — Centralized rendering for Material Design 3 input fields.
  Gathers duplicate Paint routines from Edits, Combos, Memos, etc into a single place.
  License: LGPL v3
}

interface

uses
  Classes, SysUtils, Graphics, Controls, Types, ExtCtrls,
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
    IsLocked: Boolean;
    
    { Dimensões do controle interno (TEdit, TMemo) para envolver com bordas }
    EditLeft, EditTop, EditWidth, EditHeight: Integer;
    
    { Dimensões dos painéis laterais }
    LeftPanelWidth: Integer;
    RightPanelWidth: Integer;
    
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
    LabelRight: Integer;    { Posição calculada (caso use) }
    LabelTop: Integer;      { Posição Top fixa }
    LabelText: string;      { Texto do label a ser desenhado/animado }
    LabelProgress: Single;  { 0.0 (inline container) a 1.0 (floating) }
  end;
  
  TFRMDLabelState = (lsInline, lsAnimatingToFloated, lsFloated, lsAnimatingToInline);

  { Animador leve que gerencia o ciclo temporal (0.0 a 1.0) para um TControl }
  TFRMDFloatingLabelAnimator = class
  private
    FControl: TControl;
    FTimer: TTimer;
    FProgress: Single;
    FState: TFRMDLabelState;
    procedure TimerTick(Sender: TObject);
  public
    constructor Create(AControl: TControl);
    destructor Destroy; override;
    procedure FloatLabel;
    procedure InlineLabel;
    procedure SnapTo(AValue: Single); { Para setup imediato sem animação }
    property Progress: Single read FProgress;
    property State: TFRMDLabelState read FState;
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
  InlineY: Integer;
  FloatY: Integer;
  CurrY: Integer;
  CurrX: Integer;
  LabelH, PenW: Integer;
  NotchLeft, NotchRight: Integer;
begin
  CR := P.BorderRadius * 2;
  DecoBottom := P.Rect.Bottom - P.BottomMargin;

  { Extensão horizontal do sublinhado/borda — sempre cobre o container inteiro,
    incluindo painéis de ícones (esquerdo e direito), conforme MD3 spec }
  LeftPos  := P.Rect.Left;
  RightPos := P.Rect.Right;

  { MD3 Outlined: a borda começa na metade do label flutuante, criando o
    efeito visual de "notch" onde o label senta sobre a borda superior.
    Standard/Filled: o sublinhado fica na base do TEdit. }
  if P.Variant = mvOutlined then
  begin
    if P.LabelText <> '' then
    begin
      P.Canvas.Font.Assign(P.LabelFont);
      if P.Canvas.Font.Size > 7 then P.Canvas.Font.Size := P.Canvas.Font.Size - 1;
      LabelH := P.Canvas.TextHeight(P.LabelText);
      FieldTop := P.LabelTop + LabelH div 2;
    end
    else
      FieldTop := P.Rect.Top;
  end
  else
  begin
    FieldTop := P.EditTop - 2;
    if FieldTop < 0 then FieldTop := 0;
  end;

  { Passo 1: Preenchimento do fundo }
  P.Canvas.Pen.Width   := 1;
  P.Canvas.Pen.Color   := P.BgColor;
  P.Canvas.Brush.Color := P.BgColor;
  
  if P.Variant = mvFilled then
  begin
    { MD3 spec: filled variant has top corners rounded, bottom corners square.
      Desenhamos um RoundRect completo e preenchemos a parte inferior com retângulo
      para obter cantos arredondados apenas no topo, sem criar TBGRABitmap. }
    if (P.Rect.Right <= 0) or (P.Rect.Bottom <= 0) then Exit;
    { MD3 spec: Filled fields always use SurfaceContainerHighest as background.
      Locked/Disabled states have their own colors via P.BgColor. }
    if P.IsEnabled and (not P.IsLocked) then
    begin
      P.Canvas.Brush.Color := MD3Colors.SurfaceContainerHighest;
      P.Canvas.Pen.Color   := MD3Colors.SurfaceContainerHighest;
    end
    else
    begin
      P.Canvas.Brush.Color := P.BgColor;
      P.Canvas.Pen.Color   := P.BgColor;
    end;
    { Desenha retângulo arredondado completo }
    P.Canvas.RoundRect(P.Rect.Left, P.Rect.Top, P.Rect.Right, DecoBottom, CR, CR);
    { Preenche a metade inferior com cantos retos }
    P.Canvas.FillRect(P.Rect.Left, P.Rect.Top + CR div 2, P.Rect.Right, DecoBottom);
  end
  else
  begin
    P.Canvas.FillRect(P.Rect);
  end;

  { Passo 2: Decoração do campo (Borda/Sublinhado) }
  if P.IsLocked then
    P.Canvas.Pen.Color := P.DisabledColor
  else
    P.Canvas.Pen.Color := P.DecoColor;

  case P.Variant of
    mvStandard, mvFilled:
    begin
      if P.IsLocked then
      begin
        { Locked: linha sólida OnSurfaceVariant }
        P.Canvas.Line(LeftPos, DecoBottom - 1, RightPos, DecoBottom - 1);
      end
      else if P.IsFocused and P.IsEnabled then
      begin
        P.Canvas.Line(LeftPos, DecoBottom - 2, RightPos, DecoBottom - 2);
        P.Canvas.Line(LeftPos, DecoBottom - 1, RightPos, DecoBottom - 1);
      end else
        P.Canvas.Line(LeftPos, DecoBottom - 1, RightPos, DecoBottom - 1);
    end;
    mvOutlined:
    begin
      if P.IsLocked then
        PenW := 1
      else if P.IsFocused and P.IsEnabled then
        PenW := 2
      else
        PenW := 1;

      { GDI outlined border — always draw with Pen.Width=1 for
        pixel-perfect uniform edges.  For focused state (PenW=2),
        draw two concentric 1px RoundRects to guarantee identical
        thickness on all four sides regardless of GDI pen behavior. }
      P.Canvas.Pen.Width   := 1;
      P.Canvas.Brush.Style := bsClear;
      P.Canvas.RoundRect(LeftPos, FieldTop, RightPos, DecoBottom, CR, CR);
      if PenW >= 2 then
        P.Canvas.RoundRect(LeftPos + 1, FieldTop + 1,
          RightPos - 1, DecoBottom - 1, CR, CR);

      { MD3 Notch: paint background over the top border where the
        floating label sits, creating the characteristic "cutout". }
      if (P.LabelText <> '') and (P.LabelProgress > 0.3) then
      begin
        P.Canvas.Font.Assign(P.LabelFont);
        if P.Canvas.Font.Size > 7 then P.Canvas.Font.Size := P.Canvas.Font.Size - 1;
        NotchLeft  := P.EditLeft - 4;
        NotchRight := P.EditLeft + P.Canvas.TextWidth(P.LabelText);
        if P.IsRequired then
          NotchRight := NotchRight + P.Canvas.TextWidth(' *') + 2;
        NotchRight := NotchRight + 4;
        P.Canvas.Pen.Style   := psClear;
        P.Canvas.Brush.Style := bsSolid;
        P.Canvas.Brush.Color := P.ParentBgColor;
        P.Canvas.FillRect(NotchLeft, FieldTop - 1, NotchRight, FieldTop + PenW + 1);
        P.Canvas.Pen.Style := psSolid;
      end;

      P.Canvas.Pen.Width   := 1;
      P.Canvas.Brush.Style := bsSolid;
    end;
  end;

  { Passo 3: Label animado (MD3 Floating Label) e Asterisco Required ("*") }
  if P.LabelText <> '' then
  begin
    P.Canvas.Font.Assign(P.LabelFont);
    
    if P.LabelProgress > 0.5 then
      if P.Canvas.Font.Size > 7 then P.Canvas.Font.Size := P.Canvas.Font.Size - 1;
      
    if P.LabelProgress < 1.0 then 
    begin
      if not P.IsFocused then
        P.Canvas.Font.Color := P.HelperColor
      else
        P.Canvas.Font.Color := P.DecoColor;
    end
    else
    begin
      if P.IsFocused and P.IsEnabled then
        P.Canvas.Font.Color := P.DecoColor
      else
        P.Canvas.Font.Color := P.HelperColor;
    end;
    
    { Calcula posições }
    { Y de repouso (Inline placeholder): centro vertical do campo de texto }
    { Y Flutuante (Floated): topo da variante reservado para o label }
    P.Canvas.Brush.Style := bsClear;
    
    InlineY := P.EditTop + (P.EditHeight - P.Canvas.TextHeight(P.LabelText)) div 2;
    FloatY := P.LabelTop; // Fornecido pelos componentes (geralmente 4 ou topo)
    if FloatY < 0 then FloatY := 0;
    
    CurrY := Round(InlineY + (FloatY - InlineY) * P.LabelProgress);
    CurrX := P.EditLeft;
    
    P.Canvas.TextOut(CurrX, CurrY, P.LabelText);
    
    if P.IsRequired then
    begin
      P.Canvas.Font.Color := P.DecoColor;
      P.Canvas.TextOut(CurrX + P.Canvas.TextWidth(P.LabelText) + 2, CurrY, ' *');
    end;
    
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
    P.Canvas.Font.Size := 7;
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

{ TFRMDFloatingLabelAnimator }

constructor TFRMDFloatingLabelAnimator.Create(AControl: TControl);
begin
  inherited Create;
  FControl := AControl;
  FTimer := TTimer.Create(nil);
  FTimer.Enabled := False;
  FTimer.Interval := 16; { ~60FPS }
  FTimer.OnTimer := @TimerTick;
  FProgress := 1.0;
  FState := lsFloated;
end;

destructor TFRMDFloatingLabelAnimator.Destroy;
begin
  FreeAndNil(FTimer);
  inherited Destroy;
end;

procedure TFRMDFloatingLabelAnimator.SnapTo(AValue: Single);
begin
  FTimer.Enabled := False;
  FProgress := AValue;
  if FProgress <= 0.0 then FState := lsInline
  else FState := lsFloated;
  if Assigned(FControl) then FControl.Invalidate;
end;

procedure TFRMDFloatingLabelAnimator.FloatLabel;
begin
  if (FState = lsFloated) or (FState = lsAnimatingToFloated) then Exit;
  FState := lsAnimatingToFloated;
  FTimer.Enabled := True;
end;

procedure TFRMDFloatingLabelAnimator.InlineLabel;
begin
  if (FState = lsInline) or (FState = lsAnimatingToInline) then Exit;
  FState := lsAnimatingToInline;
  FTimer.Enabled := True;
end;

procedure TFRMDFloatingLabelAnimator.TimerTick(Sender: TObject);
begin
  { Não desperdiça CPU se o controle está invisível }
  if Assigned(FControl) and (not FControl.IsVisible) then Exit;

  if FState = lsAnimatingToFloated then
  begin
    FProgress := FProgress + 0.15;
    if FProgress >= 1.0 then
    begin
      FProgress := 1.0;
      FState := lsFloated;
      FTimer.Enabled := False;
    end;
  end
  else if FState = lsAnimatingToInline then
  begin
    FProgress := FProgress - 0.15;
    if FProgress <= 0.0 then
    begin
      FProgress := 0.0;
      FState := lsInline;
      FTimer.Enabled := False;
    end;
  end;
  if Assigned(FControl) then FControl.Invalidate;
end;

end.
