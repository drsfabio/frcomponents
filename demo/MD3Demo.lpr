program MD3Demo;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, uFmDemo, uFmView;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TFmDemo, FmDemo);
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
