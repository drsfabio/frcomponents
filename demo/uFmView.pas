unit uFmView;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, FRMaterialEdit, FRMaterialDateEdit,
  FRMaterialComboEdit, FRMaterialCheckComboEdit, FRMaterialMaskEdit, FRMaterialCurrencyEdit,
  FRMaterialSpinEdit, FRMaterialSearchEdit, FRMaterial3Button, FRMaterial3Chip, FRMaterial3Progress,
  FRMaterial3Divider, FRMaterial3Sheet, FRMaterial3Nav, FRMaterial3AppBar, FRMaterial3Tabs,
  FRMaterialThemeManager;

type

  { TFmView }

  TFmView = class(TForm)
    FRMaterialAppBar1: TFRMaterialAppBar;
    FRMaterialNavRail1: TFRMaterialNavRail;
    FRMaterialTabs1: TFRMaterialTabs;
    FRMaterialThemeManager1: TFRMaterialThemeManager;
  private

  public

  end;

var
  FFmView: TFmView;

implementation

{$R *.lfm}

end.

