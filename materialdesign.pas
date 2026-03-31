{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit materialdesign;

{$warn 5023 off : no warning about unused units}
interface

uses
  FRMaterialTheme, FRMaterialIcons, FRMaterialMasks, FRMaterialEdit, FRMaterialDateEdit, 
  FRMaterialComboEdit, FRMaterialCheckComboEdit, FRMaterialMaskEdit, FRMaterialCurrencyEdit, 
  FRMaterialMemoEdit, FRMaterialSpinEdit, FRMaterialSearchEdit, FRMaterial3Base, 
  FRMaterial3Button, FRMaterial3FAB, FRMaterial3Toggle, FRMaterial3Chip, FRMaterial3Slider, 
  FRMaterial3Progress, FRMaterial3Divider, FRMaterial3Dialog, FRMaterial3Snackbar, 
  FRMaterial3Tooltip, FRMaterial3List, FRMaterial3Menu, FRMaterial3Tabs, FRMaterial3AppBar, 
  FRMaterial3Nav, FRMaterial3TimePicker, FRMaterial3Sheet, FRMaterial3TreeView, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('FRMaterialEdit', @FRMaterialEdit.Register);
  RegisterUnit('FRMaterialDateEdit', @FRMaterialDateEdit.Register);
  RegisterUnit('FRMaterialComboEdit', @FRMaterialComboEdit.Register);
  RegisterUnit('FRMaterialCheckComboEdit', @FRMaterialCheckComboEdit.Register);
  RegisterUnit('FRMaterialMaskEdit', @FRMaterialMaskEdit.Register);
  RegisterUnit('FRMaterialCurrencyEdit', @FRMaterialCurrencyEdit.Register);
  RegisterUnit('FRMaterialMemoEdit', @FRMaterialMemoEdit.Register);
  RegisterUnit('FRMaterialSpinEdit', @FRMaterialSpinEdit.Register);
  RegisterUnit('FRMaterialSearchEdit', @FRMaterialSearchEdit.Register);
  RegisterUnit('FRMaterial3Button', @FRMaterial3Button.Register);
  RegisterUnit('FRMaterial3FAB', @FRMaterial3FAB.Register);
  RegisterUnit('FRMaterial3Toggle', @FRMaterial3Toggle.Register);
  RegisterUnit('FRMaterial3Chip', @FRMaterial3Chip.Register);
  RegisterUnit('FRMaterial3Slider', @FRMaterial3Slider.Register);
  RegisterUnit('FRMaterial3Progress', @FRMaterial3Progress.Register);
  RegisterUnit('FRMaterial3Divider', @FRMaterial3Divider.Register);
  RegisterUnit('FRMaterial3Dialog', @FRMaterial3Dialog.Register);
  RegisterUnit('FRMaterial3Snackbar', @FRMaterial3Snackbar.Register);
  RegisterUnit('FRMaterial3Tooltip', @FRMaterial3Tooltip.Register);
  RegisterUnit('FRMaterial3List', @FRMaterial3List.Register);
  RegisterUnit('FRMaterial3Menu', @FRMaterial3Menu.Register);
  RegisterUnit('FRMaterial3Tabs', @FRMaterial3Tabs.Register);
  RegisterUnit('FRMaterial3AppBar', @FRMaterial3AppBar.Register);
  RegisterUnit('FRMaterial3Nav', @FRMaterial3Nav.Register);
  RegisterUnit('FRMaterial3TimePicker', @FRMaterial3TimePicker.Register);
  RegisterUnit('FRMaterial3Sheet', @FRMaterial3Sheet.Register);
  RegisterUnit('FRMaterial3TreeView', @FRMaterial3TreeView.Register);
end;

initialization
  RegisterPackage('materialdesign', @Register);
end.
