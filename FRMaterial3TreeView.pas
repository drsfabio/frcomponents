unit FRMaterial3TreeView;

{$mode objfpc}{$H+}

{ Material Design 3 — TreeView.

  TFRMaterialTreeView — Hierarchical tree with expand/collapse,
  leading icons, selection, and scroll support.

  License: LGPL v3
}

interface

uses
  Classes, SysUtils, Controls, Graphics, Forms,
  {$IFDEF FPC} LCLType, LResources, {$ENDIF}
  BGRABitmap, BGRABitmapTypes, FRMaterial3Base, FRMaterialIcons, FRMaterialTheme;

type
  TFRMaterialTreeNode = class;
  TFRMaterialTreeNodes = class;

  TFRMaterialTreeNode = class(TCollectionItem)
  private
    FCaption: string;
    FIconMode: TFRIconMode;
    FExpanded: Boolean;
    FLevel: Integer;
    FChildren: TFRMaterialTreeNodes;
    FTag: PtrInt;
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    function HasChildren: Boolean;
  published
    property Caption: string read FCaption write FCaption;
    property IconMode: TFRIconMode read FIconMode write FIconMode;
    property Expanded: Boolean read FExpanded write FExpanded default False;
    property Level: Integer read FLevel write FLevel default 0;
    property Children: TFRMaterialTreeNodes read FChildren;
    property Tag: PtrInt read FTag write FTag default 0;
  end;

  TFRMaterialTreeNodes = class(TCollection)
  private
    FOwner: TPersistent;
    function GetItem(Index: Integer): TFRMaterialTreeNode;
    procedure SetItem(Index: Integer; AValue: TFRMaterialTreeNode);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TFRMaterialTreeNode;
    property Items[Index: Integer]: TFRMaterialTreeNode read GetItem write SetItem; default;
  end;

  TFRMaterialTreeView = class(TFRMaterial3Control)
  private
    FNodes: TFRMaterialTreeNodes;
    FSelectedNode: TFRMaterialTreeNode;
    FOnSelectionChange: TNotifyEvent;
    FOnExpand: TNotifyEvent;
    FOnCollapse: TNotifyEvent;
    FScrollOffset: Integer;
    FShowDividers: Boolean;
    FShowIcons: Boolean;
    FItemHeight: Integer;
    FIndent: Integer;
    { Flat list for rendering }
    FFlatList: TList;
    procedure RebuildFlatList;
    procedure CollectNodes(ANodes: TFRMaterialTreeNodes; ALevel: Integer);
    procedure SetSelectedNode(AValue: TFRMaterialTreeNode);
    function GetEffectiveItemHeight: Integer;
  protected
    function PaintCached(ABmp: TBGRABitmap): Boolean; override;
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property SelectedNode: TFRMaterialTreeNode read FSelectedNode write SetSelectedNode;
  published
    property Nodes: TFRMaterialTreeNodes read FNodes;
    property ShowDividers: Boolean read FShowDividers write FShowDividers default False;
    property ShowIcons: Boolean read FShowIcons write FShowIcons default True;
    property ItemHeight: Integer read FItemHeight write FItemHeight default 48;
    property Indent: Integer read FIndent write FIndent default 24;
    property OnSelectionChange: TNotifyEvent read FOnSelectionChange write FOnSelectionChange;
    property OnExpand: TNotifyEvent read FOnExpand write FOnExpand;
    property OnCollapse: TNotifyEvent read FOnCollapse write FOnCollapse;
    property Align;
    property Anchors;
    property BorderSpacing;
    property Constraints;
    property Cursor;
    property Enabled;
    property Font;
    property ParentFont;
    property PopupMenu;
    property ShowHint;
    property ParentShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
  end;

procedure Register;

implementation

uses Math;

{ ── TFRMaterialTreeNode ── }

constructor TFRMaterialTreeNode.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FCaption := '';
  FIconMode := imClear;
  FExpanded := False;
  FLevel := 0;
  FChildren := TFRMaterialTreeNodes.Create(Self);
  FTag := 0;
end;

destructor TFRMaterialTreeNode.Destroy;
begin
  FChildren.Free;
  inherited Destroy;
end;

function TFRMaterialTreeNode.HasChildren: Boolean;
begin
  Result := FChildren.Count > 0;
end;

{ ── TFRMaterialTreeNodes ── }

constructor TFRMaterialTreeNodes.Create(AOwner: TPersistent);
begin
  inherited Create(TFRMaterialTreeNode);
  FOwner := AOwner;
end;

function TFRMaterialTreeNodes.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TFRMaterialTreeNodes.GetItem(Index: Integer): TFRMaterialTreeNode;
begin
  Result := TFRMaterialTreeNode(inherited Items[Index]);
end;

procedure TFRMaterialTreeNodes.SetItem(Index: Integer; AValue: TFRMaterialTreeNode);
begin
  inherited Items[Index] := AValue;
end;

function TFRMaterialTreeNodes.Add: TFRMaterialTreeNode;
begin
  Result := TFRMaterialTreeNode(inherited Add);
end;

{ ── TFRMaterialTreeView ── }

constructor TFRMaterialTreeView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FNodes := TFRMaterialTreeNodes.Create(Self);
  FSelectedNode := nil;
  FScrollOffset := 0;
  FShowDividers := False;
  FShowIcons := True;
  FItemHeight := 48;
  FIndent := 24;
  FFlatList := TList.Create;
  Width := 300;
  Height := 400;
end;

function TFRMaterialTreeView.GetEffectiveItemHeight: Integer;
begin
  Result := FItemHeight + MD3DensityDelta(Density);
end;

destructor TFRMaterialTreeView.Destroy;
begin
  FFlatList.Free;
  FNodes.Free;
  inherited Destroy;
end;

procedure TFRMaterialTreeView.CollectNodes(ANodes: TFRMaterialTreeNodes; ALevel: Integer);
var
  I: Integer;
  Node: TFRMaterialTreeNode;
begin
  for I := 0 to ANodes.Count - 1 do
  begin
    Node := ANodes[I];
    Node.FLevel := ALevel;
    FFlatList.Add(Node);
    if Node.FExpanded and Node.HasChildren then
      CollectNodes(Node.FChildren, ALevel + 1);
  end;
end;

procedure TFRMaterialTreeView.RebuildFlatList;
begin
  FFlatList.Clear;
  CollectNodes(FNodes, 0);
end;

procedure TFRMaterialTreeView.SetSelectedNode(AValue: TFRMaterialTreeNode);
begin
  if FSelectedNode <> AValue then
  begin
    FSelectedNode := AValue;
    InvalidatePaintCache;
    Invalidate;
    if Assigned(FOnSelectionChange) then
      FOnSelectionChange(Self);
  end;
end;

function TFRMaterialTreeView.PaintCached(ABmp: TBGRABitmap): Boolean;
var
  I, yPos, xOff, ih: Integer;
  Node: TFRMaterialTreeNode;
  icoClr: TColor;
  iconBmp: TBGRABitmap;
  chevMode: TFRIconMode;
  nodeIcon: TFRIconMode;
  chevSz, nodeSz, padX, chevW, nodeW: Integer;
begin
  Result := True;
  RebuildFlatList;
  ih := GetEffectiveItemHeight;

  { Proportional metrics based on ih (reference = 40) }
  chevSz := ih * 18 div 40;
  if chevSz < 12 then chevSz := 12;
  nodeSz := ih * 20 div 40;
  if nodeSz < 14 then nodeSz := 14;
  padX := ih * 16 div 40;
  if padX < 4 then padX := 4;
  chevW := ih * 22 div 40;
  nodeW := ih * 28 div 40;

  ABmp.Fill(ColorToBGRA(MD3Colors.Surface));

  for I := 0 to FFlatList.Count - 1 do
  begin
    Node := TFRMaterialTreeNode(FFlatList[I]);
    yPos := I * ih - FScrollOffset;
    if (yPos + ih < 0) or (yPos > Height) then Continue;

    xOff := padX + Node.FLevel * FIndent;

    { Selection highlight }
    if Node = FSelectedNode then
      ABmp.FillRoundRectAntialias(padX div 2, yPos + 2, Width - padX div 2, yPos + ih - 2,
        14, 14, ColorToBGRA(MD3Colors.SecondaryContainer));

    { Expand/collapse chevron for parent nodes }
    if Node.HasChildren then
    begin
      if Node.FExpanded then
        chevMode := imExpandMore
      else
        chevMode := imExpandLess;

      icoClr := MD3Colors.OnSurfaceVariant;
      iconBmp := FRGetCachedIcon(chevMode, FRColorToSVGHex(icoClr), 2.0, chevSz, chevSz);

      if iconBmp <> nil then
        ABmp.PutImage(xOff, yPos + (ih - chevSz) div 2, iconBmp, dmDrawWithTransparency);

      xOff := xOff + chevW;
    end
    else
      xOff := xOff + chevW; { align leaf items with parent content }

    { Node icon }
    if FShowIcons and (Node.FIconMode <> imClear) then
    begin
      if Node = FSelectedNode then
        icoClr := MD3Colors.OnSecondaryContainer
      else
        icoClr := MD3Colors.OnSurfaceVariant;

      nodeIcon := Node.FIconMode;
      iconBmp := FRGetCachedIcon(nodeIcon, FRColorToSVGHex(icoClr), 2.0, nodeSz, nodeSz);

      if iconBmp <> nil then
        ABmp.PutImage(xOff, yPos + (ih - nodeSz) div 2, iconBmp, dmDrawWithTransparency);

      xOff := xOff + nodeW;
    end;

    { Divider }
    if FShowDividers and (I < FFlatList.Count - 1) then
      ABmp.DrawLineAntialias(padX, yPos + ih - 1, Width - 1, yPos + ih - 1,
        ColorToBGRA(MD3Colors.OutlineVariant), 1);
  end;
end;

procedure TFRMaterialTreeView.Paint;
var
  I, yPos, xOff, ih: Integer;
  Node: TFRMaterialTreeNode;
  aRect: TRect;
  clr: TColor;
  padX, chevW, nodeW: Integer;
begin
  inherited Paint;

  { Text labels — second pass on Canvas }
  RebuildFlatList;
  ih := GetEffectiveItemHeight;

  padX := ih * 16 div 40;
  if padX < 4 then padX := 4;
  chevW := ih * 22 div 40;
  nodeW := ih * 28 div 40;

  for I := 0 to FFlatList.Count - 1 do
  begin
    Node := TFRMaterialTreeNode(FFlatList[I]);
    yPos := I * ih - FScrollOffset;
    if (yPos + ih < 0) or (yPos > Height) then Continue;

    xOff := padX + Node.FLevel * FIndent + chevW; { past chevron area }

    if FShowIcons and (Node.FIconMode <> imClear) then
      xOff := xOff + nodeW;

    if Node = FSelectedNode then
      clr := MD3Colors.OnSecondaryContainer
    else
      clr := MD3Colors.OnSurface;

    aRect := Rect(xOff, yPos, Width - padX, yPos + ih);
    Canvas.Font.Size := ih * 10 div 40;
    if Canvas.Font.Size < 7 then Canvas.Font.Size := 7;
    if Node.HasChildren then
      Canvas.Font.Style := [fsBold]
    else
      Canvas.Font.Style := [];
    MD3DrawText(Canvas, Node.FCaption, aRect, clr, taLeftJustify, True);
  end;
  Canvas.Font.Style := [];
end;

procedure TFRMaterialTreeView.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  idx, xOff, chevEnd, ih, padX, chevW: Integer;
  Node: TFRMaterialTreeNode;
begin
  inherited;
  if Button <> mbLeft then Exit;

  RebuildFlatList;
  ih := GetEffectiveItemHeight;
  padX := ih * 16 div 40;
  if padX < 4 then padX := 4;
  chevW := ih * 22 div 40;

  idx := (Y + FScrollOffset) div ih;
  if (idx < 0) or (idx >= FFlatList.Count) then Exit;

  Node := TFRMaterialTreeNode(FFlatList[idx]);
  xOff := padX + Node.FLevel * FIndent;
  chevEnd := xOff + chevW;

  { If clicked on chevron area and node has children → toggle expand }
  if Node.HasChildren and (X >= xOff) and (X < chevEnd) then
  begin
    Node.FExpanded := not Node.FExpanded;
    if Node.FExpanded then
    begin
      if Assigned(FOnExpand) then FOnExpand(Self);
    end
    else
    begin
      if Assigned(FOnCollapse) then FOnCollapse(Self);
    end;
    InvalidatePaintCache;
    Invalidate;
  end
  else
  begin
    { Select node }
    SetSelectedNode(Node);
  end;
end;

function TFRMaterialTreeView.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
var
  maxScroll, ih: Integer;
begin
  RebuildFlatList;
  ih := GetEffectiveItemHeight;
  maxScroll := Max(0, FFlatList.Count * ih - Height);
  FScrollOffset := FScrollOffset - (WheelDelta div 3);
  if FScrollOffset < 0 then FScrollOffset := 0;
  if FScrollOffset > maxScroll then FScrollOffset := maxScroll;
  InvalidatePaintCache;
  Invalidate;
  Result := True;
end;

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialtreeview_icon.lrs}
  {$ENDIF}
  RegisterComponents('Material Design 3', [TFRMaterialTreeView]);
end;

end.
