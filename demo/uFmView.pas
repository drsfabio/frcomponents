unit uFmView;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, FRMaterialEdit, FRMaterialDateEdit,
  FRMaterialComboEdit, FRMaterialCheckComboEdit, FRMaterialMaskEdit, FRMaterialCurrencyEdit,
  FRMaterialSpinEdit, FRMaterialSearchEdit, FRMaterial3Button, FRMaterial3Chip, FRMaterial3Progress,
  FRMaterial3Divider, FRMaterial3Sheet, FRMaterial3Nav, FRMaterial3AppBar, FRMaterial3Tabs,
  FRMaterialThemeManager, FRMaterial3Dialog, FRMaterial3Slider, FRMaterial3TimePicker;

type

  { TFmView }

  TFmView = class(TForm)
    FRMaterialAppBar1: TFRMaterialAppBar;
    FRMaterialButton1: TFRMaterialButton;
    FRMaterialButton2: TFRMaterialButton;
    FRMaterialChip1: TFRMaterialChip;
    FRMaterialCircularProgress1: TFRMaterialCircularProgress;
    FRMaterialDateEdit1: TFRMaterialDateEdit;
    FRMaterialDivider1: TFRMaterialDivider;
    FRMaterialLinearProgress1: TFRMaterialLinearProgress;
    FRMaterialLinearProgress2: TFRMaterialLinearProgress;
    FRMaterialLoadingIndicator1: TFRMaterialLoadingIndicator;
    FRMaterialNavRail1: TFRMaterialNavRail;
    FRMaterialSegmentedButton1: TFRMaterialSegmentedButton;
    FRMaterialSlider1: TFRMaterialSlider;
    FRMaterialThemeManager1: TFRMaterialThemeManager;
    FRMaterialThemeManager2: TFRMaterialThemeManager;
    FRMaterialTimePicker1: TFRMaterialTimePicker;
    FRMaterialTimePicker2: TFRMaterialTimePicker;
  private

  public

  end;

var
  FFmView: TFmView;

implementation

{$R *.lfm}

end.

