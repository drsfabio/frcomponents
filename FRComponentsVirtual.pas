{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit FRComponentsVirtual;

{$warn 5023 off : no warning about unused units}
interface

uses
  FRMaterial3VirtualDataGrid, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('FRMaterial3VirtualDataGrid', @FRMaterial3VirtualDataGrid.Register);
end;

initialization
  RegisterPackage('FRComponentsVirtual', @Register);
end.
