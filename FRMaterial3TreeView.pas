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
  BGRABitmap, BGRABitmapTypes, FRMaterial3Base, FRMaterialIcons;

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
  protected
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
    property Visible;
    property Enabled;
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
    Invalidate;
    if Assigned(FOnSelectionChange) then
      FOnSelectionChange(Self);
  end;
end;

procedure TFRMaterialTreeView.Paint;
var
  bmp: TBGRABitmap;
  I, yPos, xOff: Integer;
  Node: TFRMaterialTreeNode;
  aRect: TRect;
  clr, icoClr: TColor;
  svg: string;
  iconBmp: TBGRABitmap;
  chevMode: TFRIconMode;
  nodeIcon: TFRIconMode;
begin
  RebuildFlatList;

  bmp := TBGRABitmap.Create(Width, Height, ColorToBGRA(MD3Colors.Surface));
  try
    for I := 0 to FFlatList.Count - 1 do
    begin
      Node := TFRMaterialTreeNode(FFlatList[I]);
      yPos := I * FItemHeight - FScrollOffset;
      if (yPos + FItemHeight < 0) or (yPos > Height) then Continue;

      xOff := 16 + Node.FLevel * FIndent;

      { Selection highlight }
      if Node = FSelectedNode then
        bmp.FillRoundRectAntialias(8, yPos + 2, Width - 8, yPos + FItemHeight - 2,
          14, 14, ColorToBGRA(MD3Colors.SecondaryContainer));

      { Expand/collapse chevron for parent nodes }
      if Node.HasChildren then
      begin
        if Node.FExpanded then
          chevMode := imExpandMore
        else
          chevMode := imExpandLess;

        icoClr := MD3Colors.OnSurfaceVariant;
        iconBmp := FRGetCachedIcon(chevMode, FRColorToSVGHex(icoClr), 2.0, 18, 18);
        
        if iconBmp <> nil then
          bmp.PutImage(xOff, yPos + (FItemHeight - 18) div 2, iconBmp, dmDrawWithTransparency);

        xOff := xOff + 22;
      end
      else
        xOff := xOff + 22; { align leaf items with parent content }

      { Node icon }
      if FShowIcons and (Node.FIconMode <> imClear) then
      begin
        if Node = FSelectedNode then
          icoClr := MD3Colors.OnSecondaryContainer
        else
          icoClr := MD3Colors.OnSurfaceVariant;
          
        nodeIcon := Node.FIconMode;
        iconBmp := FRGetCachedIcon(nodeIcon, FRColorToSVGHex(icoClr), 2.0, 20, 20);
        
        if iconBmp <> nil then
          bmp.PutImage(xOff, yPos + (FItemHeight - 20) div 2, iconBmp, dmDrawWithTransparency);
          
        xOff := xOff + 28;
      end;

      { Divider }
      if FShowDividers and (I < FFlatList.Count - 1) then
        bmp.DrawLineAntialias(16, yPos + FItemHeight - 1, Width - 1, yPos + FItemHeight - 1,
          ColorToBGRA(MD3Colors.OutlineVariant), 1);
    end;

    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;

  { Text labels — second pass on Canvas }
  for I := 0 to FFlatList.Count - 1 do
  begin
    Node := TFRMaterialTreeNode(FFlatList[I]);
    yPos := I * FItemHeight - FScrollOffset;
    if (yPos + FItemHeight < 0) or (yPos > Height) then Continue;

    xOff := 16 + Node.FLevel * FIndent + 22; { past chevron area }

    if FShowIcons and (Node.FIconMode <> imClear) then
      xOff := xOff + 28;

    if Node = FSelectedNode then
      clr := MD3Colors.OnSecondaryContainer
    else
      clr := MD3Colors.OnSurface;

    aRect := Rect(xOff, yPos, Width - 16, yPos + FItemHeight);
    Canvas.Font.Size := 10;
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
  idx, xOff, chevEnd: Integer;
  Node: TFRMaterialTreeNode;
begin
  inherited;
  if Button <> mbLeft then Exit;

  RebuildFlatList;
  idx := (Y + FScrollOffset) div FItemHeight;
  if (idx < 0) or (idx >= FFlatList.Count) then Exit;

  Node := TFRMaterialTreeNode(FFlatList[idx]);
  xOff := 16 + Node.FLevel * FIndent;
  chevEnd := xOff + 22;

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
  maxScroll: Integer;
begin
  RebuildFlatList;
  maxScroll := Max(0, FFlatList.Count * FItemHeight - Height);
  FScrollOffset := FScrollOffset - (WheelDelta div 3);
  if FScrollOffset < 0 then FScrollOffset := 0;
  if FScrollOffset > maxScroll then FScrollOffset := maxScroll;
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
