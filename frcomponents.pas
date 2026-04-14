{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit FRComponents;

{$warn 5023 off : no warning about unused units}
interface

uses
  FRMaterial3AppBar, FRMaterial3Badge, FRMaterial3Base, FRMaterial3Button, 
  FRMaterial3Card, FRMaterial3Carousel, FRMaterial3Chip, FRMaterial3Combo, 
  FRMaterial3DataGrid, FRMaterial3DatePicker, FRMaterial3Dialog, 
  FRMaterial3Divider, FRMaterial3FAB, FRMaterial3GridPanel, FRMaterial3Label, 
  FRMaterial3List, FRMaterial3Menu, FRMaterial3Nav, FRMaterial3PageControl, 
  FRMaterial3Progress, FRMaterial3Sheet, FRMaterial3Slider, 
  FRMaterial3Snackbar, FRMaterial3Tabs, FRMaterial3TimePicker, 
  FRMaterial3TitleBar, FRMaterial3Toggle, FRMaterial3Toolbox, 
  FRMaterial3Tooltip, FRMaterial3TreeView, FRMaterialCheckComboEdit, 
  FRMaterialDateEdit, FRMaterialEdit, FRMaterialFieldPainter, FRMaterialIcons, 
  FRMaterialInternalEdits, FRMaterialMaskEdit, FRMaterialMasks, 
  FRMaterialMemoEdit, FRMaterialSearchEdit, FRMaterialSpinEdit, 
  FRMaterialTheme, FRMaterialThemeManager, FRMaterial3ProjectTemplate, 
  FRMaterial3MainForm, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('FRMaterial3AppBar', @FRMaterial3AppBar.Register);
  RegisterUnit('FRMaterial3Badge', @FRMaterial3Badge.Register);
  RegisterUnit('FRMaterial3Button', @FRMaterial3Button.Register);
  RegisterUnit('FRMaterial3Card', @FRMaterial3Card.Register);
  RegisterUnit('FRMaterial3Carousel', @FRMaterial3Carousel.Register);
  RegisterUnit('FRMaterial3Chip', @FRMaterial3Chip.Register);
  RegisterUnit('FRMaterial3Combo', @FRMaterial3Combo.Register);
  RegisterUnit('FRMaterial3DataGrid', @FRMaterial3DataGrid.Register);
  RegisterUnit('FRMaterial3DatePicker', @FRMaterial3DatePicker.Register);
  RegisterUnit('FRMaterial3Dialog', @FRMaterial3Dialog.Register);
  RegisterUnit('FRMaterial3Divider', @FRMaterial3Divider.Register);
  RegisterUnit('FRMaterial3FAB', @FRMaterial3FAB.Register);
  RegisterUnit('FRMaterial3GridPanel', @FRMaterial3GridPanel.Register);
  RegisterUnit('FRMaterial3Label', @FRMaterial3Label.Register);
  RegisterUnit('FRMaterial3List', @FRMaterial3List.Register);
  RegisterUnit('FRMaterial3Menu', @FRMaterial3Menu.Register);
  RegisterUnit('FRMaterial3Nav', @FRMaterial3Nav.Register);
  RegisterUnit('FRMaterial3PageControl', @FRMaterial3PageControl.Register);
  RegisterUnit('FRMaterial3Progress', @FRMaterial3Progress.Register);
  RegisterUnit('FRMaterial3Sheet', @FRMaterial3Sheet.Register);
  RegisterUnit('FRMaterial3Slider', @FRMaterial3Slider.Register);
  RegisterUnit('FRMaterial3Snackbar', @FRMaterial3Snackbar.Register);
  RegisterUnit('FRMaterial3Tabs', @FRMaterial3Tabs.Register);
  RegisterUnit('FRMaterial3TimePicker', @FRMaterial3TimePicker.Register);
  RegisterUnit('FRMaterial3TitleBar', @FRMaterial3TitleBar.Register);
  RegisterUnit('FRMaterial3Toggle', @FRMaterial3Toggle.Register);
  RegisterUnit('FRMaterial3Toolbox', @FRMaterial3Toolbox.Register);
  RegisterUnit('FRMaterial3Tooltip', @FRMaterial3Tooltip.Register);
  RegisterUnit('FRMaterial3TreeView', @FRMaterial3TreeView.Register);
  RegisterUnit('FRMaterialCheckComboEdit', @FRMaterialCheckComboEdit.Register);
  RegisterUnit('FRMaterialDateEdit', @FRMaterialDateEdit.Register);
  RegisterUnit('FRMaterialEdit', @FRMaterialEdit.Register);
  RegisterUnit('FRMaterialMaskEdit', @FRMaterialMaskEdit.Register);
  RegisterUnit('FRMaterialMemoEdit', @FRMaterialMemoEdit.Register);
  RegisterUnit('FRMaterialSearchEdit', @FRMaterialSearchEdit.Register);
  RegisterUnit('FRMaterialSpinEdit', @FRMaterialSpinEdit.Register);
  RegisterUnit('FRMaterialThemeManager', @FRMaterialThemeManager.Register);
  RegisterUnit('FRMaterial3ProjectTemplate', 
    @FRMaterial3ProjectTemplate.Register);
end;

initialization
  RegisterPackage('FRComponents', @Register);
end.
