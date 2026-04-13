unit FRMaterial3ProjectTemplate;

{$mode objfpc}{$H+}

{ Registers "MD3 Application" in the Lazarus IDE under File > New > Project.
  Creates a minimal project with TFRMaterialForm as the main form. }

interface

uses
  Classes, SysUtils, ProjectIntf, LazIDEIntf, Controls, Forms;

type

  { TFRMaterialFormProjectDescriptor }

  TFRMaterialFormProjectDescriptor = class(TProjectDescriptor)
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles({%H-}AProject: TLazProject): TModalResult; override;
  end;

procedure Register;

implementation

const
  SProjectName = 'MD3 Application';
  SProjectDesc = 'A Material Design 3 application with TFRMaterialForm'
    + ' (borderless window, custom TitleBar, DWM shadow, rounded corners).';

  { Source templates }
  SLprSource =
    'program md3app;'                                                + LineEnding +
    ''                                                               + LineEnding +
    '{$mode objfpc}{$H+}'                                            + LineEnding +
    ''                                                               + LineEnding +
    'uses'                                                           + LineEnding +
    '  {$IFDEF UNIX}cthreads,{$ENDIF}'                              + LineEnding +
    '  Interfaces,'                                                  + LineEnding +
    '  Forms,'                                                       + LineEnding +
    '  ufm_main;'                                                    + LineEnding +
    ''                                                               + LineEnding +
    '{$R *.res}'                                                     + LineEnding +
    ''                                                               + LineEnding +
    'begin'                                                          + LineEnding +
    '  RequireDerivedFormResource := True;'                           + LineEnding +
    '  Application.Scaled := True;'                                  + LineEnding +
    '  Application.Initialize;'                                      + LineEnding +
    '  Application.CreateForm(TFmMain, FmMain);'                     + LineEnding +
    '  Application.Run;'                                             + LineEnding +
    'end.';

  SPasSource =
    'unit ufm_main;'                                                 + LineEnding +
    ''                                                               + LineEnding +
    '{$mode objfpc}{$H+}'                                            + LineEnding +
    ''                                                               + LineEnding +
    'interface'                                                      + LineEnding +
    ''                                                               + LineEnding +
    'uses'                                                           + LineEnding +
    '  Classes, SysUtils, Forms, Controls,'                          + LineEnding +
    '  FRMaterial3Base, FRMaterial3TitleBar,'                         + LineEnding +
    '  FRMaterialTheme, FRMaterialThemeManager;'                     + LineEnding +
    ''                                                               + LineEnding +
    'type'                                                           + LineEnding +
    ''                                                               + LineEnding +
    '  { TFmMain }'                                                  + LineEnding +
    ''                                                               + LineEnding +
    '  TFmMain = class(TFRMaterialForm)'                             + LineEnding +
    '  private'                                                      + LineEnding +
    '    FThemeManager: TFRMaterialThemeManager;'                     + LineEnding +
    '  public'                                                       + LineEnding +
    '    constructor Create(AOwner: TComponent); override;'          + LineEnding +
    '  end;'                                                         + LineEnding +
    ''                                                               + LineEnding +
    'var'                                                            + LineEnding +
    '  FmMain: TFmMain;'                                             + LineEnding +
    ''                                                               + LineEnding +
    'implementation'                                                 + LineEnding +
    ''                                                               + LineEnding +
    'constructor TFmMain.Create(AOwner: TComponent);'                + LineEnding +
    'begin'                                                          + LineEnding +
    '  inherited CreateNew(AOwner);'                                 + LineEnding +
    ''                                                               + LineEnding +
    '  Caption  := ''My MD3 Application'';'                          + LineEnding +
    '  Width    := 1024;'                                            + LineEnding +
    '  Height   := 640;'                                             + LineEnding +
    '  Position := poScreenCenter;'                                  + LineEnding +
    ''                                                               + LineEnding +
    '  FThemeManager := TFRMaterialThemeManager.Create(Self);'       + LineEnding +
    '  FThemeManager.DarkMode := False;'                             + LineEnding +
    ''                                                               + LineEnding +
    '  TitleBar.Title := Caption;'                                   + LineEnding +
    'end;'                                                           + LineEnding +
    ''                                                               + LineEnding +
    'end.';

{ TFRMaterialFormProjectDescriptor }

constructor TFRMaterialFormProjectDescriptor.Create;
begin
  inherited Create;
  Name := SProjectName;
end;

function TFRMaterialFormProjectDescriptor.GetLocalizedName: string;
begin
  Result := SProjectName;
end;

function TFRMaterialFormProjectDescriptor.GetLocalizedDescription: string;
begin
  Result := SProjectDesc;
end;

function TFRMaterialFormProjectDescriptor.InitProject(
  AProject: TLazProject): TModalResult;
var
  MainFile: TLazProjectFile;
begin
  Result := inherited InitProject(AProject);
  if Result <> mrOk then Exit;

  { Main program file }
  MainFile := AProject.CreateProjectFile('md3app.lpr');
  MainFile.IsPartOfProject := True;
  AProject.AddFile(MainFile, False);
  AProject.MainFileID := 0;
  AProject.MainFile.SetSourceText(SLprSource, True);

  { Project settings }
  AProject.Title := 'MD3 Application';
  AProject.Flags := AProject.Flags - [pfMainUnitHasCreateFormStatements,
    pfMainUnitHasTitleStatement, pfMainUnitHasScaledStatement];
  AProject.AddPackageDependency('LCL');
  AProject.AddPackageDependency('FRComponents');

  Result := mrOk;
end;

function TFRMaterialFormProjectDescriptor.CreateStartFiles(
  AProject: TLazProject): TModalResult;
var
  FormFile: TLazProjectFile;
begin
  { Main form unit }
  FormFile := AProject.CreateProjectFile('ufm_main.pas');
  FormFile.IsPartOfProject := True;
  AProject.AddFile(FormFile, False);
  FormFile.SetSourceText(SPasSource, True);

  Result := mrOk;
end;

{ Registration }

procedure Register;
begin
  RegisterProjectDescriptor(TFRMaterialFormProjectDescriptor.Create);
end;

end.
