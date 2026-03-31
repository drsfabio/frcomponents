unit uFmView;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, FRMaterial3Divider, FRMaterial3Toggle,
  FRMaterial3Progress, FRMaterial3List, FRMaterial3TimePicker;

type

  { TForm1 }

  TForm1 = class(TForm)
    FRMaterialCheckBox1: TFRMaterialCheckBox;
    FRMaterialGroupBox1: TFRMaterialGroupBox;
    FRMaterialLinearProgress1: TFRMaterialLinearProgress;
    FRMaterialListView1: TFRMaterialListView;
    FRMaterialSwitch1: TFRMaterialSwitch;
    FRMaterialTimePicker1: TFRMaterialTimePicker;
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

end.

