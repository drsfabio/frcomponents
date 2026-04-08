program MD3Demo;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, uFmDemo, FRMaterial3AppBar, FRMaterial3Base, FRMaterial3Button, FRMaterial3Chip,
  FRMaterial3Dialog, FRMaterial3Divider, FRMaterial3FAB, FRMaterial3List, FRMaterial3Menu,
  FRMaterial3Nav, FRMaterial3Progress, FRMaterial3Sheet, FRMaterial3Slider, FRMaterial3Snackbar,
  FRMaterial3Tabs, FRMaterial3TimePicker, FRMaterial3Toggle, FRMaterial3Tooltip,
  FRMaterial3TreeView, FRMaterial3VirtualDataGrid, FRMaterialCheckComboEdit,
  FRMaterialComboEdit, FRMaterialCurrencyEdit, FRMaterialDateEdit, FRMaterialEdit,
  FRMaterialIcons, FRMaterialMaskEdit, FRMaterialMasks, FRMaterialMemoEdit,
  FRMaterialSearchEdit, FRMaterialSpinEdit, FRMaterialTheme, materialdesign,
  FRMaterial3DataGrid, FRMaterial3PageControl, FRMaterialFieldPainter, FRMaterialInternalEdits,
  FRMaterialThemeManager;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TFmDemo, FmDemo);
  Application.Run;
end.
