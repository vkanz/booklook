unit LookBook.Data;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet,
  LookBook.Common,
  LookBook.Interfaces;

type
  TDatabase = class(TDataModule, IPublicationInfoConsumer)
    FDConnection: TFDConnection;
    FDQuery_CreateTables: TFDQuery;
    FDQuery_InsertBook: TFDQuery;
  private
    FSQLiteVersion: string;
    procedure ReadEnvironment;
  public const
    DbName = 'lookbook.s3db';
  protected
    procedure Setup;
    procedure Teardown;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    { IPublicationInfoConsumer }
    procedure AddPublicationInfo(const AFileName: string; const AInfo: TPublicationInfo);
  end;

var
  Database: TDatabase;

implementation

uses
  Variants, IOUtils,
  FireDAC.Stan.Consts,
  LookBook.Options;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ Copy constants from implementation part of the module FireDAC.Phys.SQLite }
const
  S_FD_Normal = 'Normal';
  S_FD_Exclusive = 'Exclusive';
  S_FD_ConnParam_SQLite_OpenMode = 'OpenMode';
  S_FD_CreateUTF8 = 'CreateUTF8';
  S_FD_ReadWrite = 'ReadWrite';

{ TDatabase }

procedure TDatabase.AddPublicationInfo(const AFileName: string; const AInfo: TPublicationInfo);
begin
  FDConnection.ExecSQL(FDQuery_InsertBook.SQL.Text,
    [AFileName,
    AInfo.GetValue(0), AInfo.GetValue(1), AInfo.GetValue(2), AInfo.GetValue(3), AInfo.GetValue(4),
    AInfo.GetValue(5), AInfo.GetValue(6), AInfo.GetValue(7), AInfo.GetValue(8), AInfo.GetValue(9),
    AInfo.GetValue(10), AInfo.GetValue(11), AInfo.GetValue(12), AInfo.GetValue(13), AInfo.GetValue(14)]
  );

//  FDQuery_InsertBook.ParamByName('file_name').Value := AFileName;
//  for var I := 0 to TermCount - 1 do
//  begin
//    FDQuery_InsertBook.Params[I].Value := AInfo.GetValue(I);
//    FDQuery_InsertBook.Params[I].DataType := TFieldType.ftString;
//  end;
//  FDQuery_InsertBook.Prepare;
//  FDQuery_InsertBook.ExecSQL;
end;

procedure TDatabase.AfterConstruction;
begin
  inherited AfterConstruction;
  Setup;
end;

procedure TDatabase.BeforeDestruction;
begin
  Teardown;
  inherited BeforeDestruction;
end;

procedure TDatabase.ReadEnvironment;
var
  Ver: Variant;
begin
  Ver := FDConnection.ExecSQLScalar('select sqlite_version()');
  FSQLiteVersion := VarToStr(Ver);
end;

procedure TDatabase.Setup;
var
  DbExists: Boolean;
  DbFileName: string;
begin
  // 'C:\Users\Администратор\OneDrive\Документы\'
  DbFileName := TPath.Combine(TOptions.GetDocumentsPath, DbName);
  DbExists := TFile.Exists(DbFileName);

  FDConnection.DriverName := S_FD_SQLiteId;
  FDConnection.LoginPrompt := False;
  FDConnection.Params.Values[S_FD_ConnParam_Common_Database] := DbFileName;
{$IFDEF ANDROID}
  FDConnection.Params.Values[S_FD_ConnParam_SQLite_LockingMode] := S_FD_Exclusive;
{$ELSE}
  FDConnection.Params.Values[S_FD_ConnParam_SQLite_LockingMode] := S_FD_Normal;
{$ENDIF}
  FDConnection.Connected := True;

  if not DbExists then
    FDQuery_CreateTables.ExecSQL;

  ReadEnvironment;
end;

procedure TDatabase.Teardown;
begin
  FDConnection.Connected := False;
end;

end.
