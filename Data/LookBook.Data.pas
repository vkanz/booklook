unit LookBook.Data;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet,
  LookBook.Common,
  LookBook.Interfaces;

{
booklook
booklegger
bookashka
}

type
  TBookCollection = record
    ID: Integer;
    Name: string;
    Path: string;
    function Assigned: Boolean;
  end;

type
  TDatabase = class(TDataModule, IPublicationInfoConsumer)
    FDConnection: TFDConnection;
    FDQuery_CreateTables: TFDQuery;
    FDQuery_InsertBook: TFDQuery;
  private
    FCurrentCollection: TBookCollection;
    FSQLiteVersion: string;
    FDbFileName: string;
    procedure ReadEnvironment;
  public const
    DbName = 'booklook.s3db';
  protected
    procedure Setup;
    procedure Teardown;
    function CreateCollection(const APath: string): TBookCollection;
    function GetLastCollection: TBookCollection;
    procedure CreateDatabase;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    { IPublicationInfoConsumer }
    procedure AddPublicationInfo(const AFileName: string; const AInfo: TPublicationInfo);
    procedure BeginUpdateCollection(const APath: string);
    {}
    property DbFileName: string read FDbFileName;
  end;

var
  Database: TDatabase;

implementation

uses
  Variants, IOUtils,
  FireDAC.Stan.Consts,
  LookBook.Consts,
  LookBook.Logger,
  LookBook.Options;

const
  { SQLite's date-time formats }
  SQLDate = 'yyyy-mm-dd';
  SQLTime = 'hh:nn:ss';
  SQLDateTime = 'yyyy-mm-dd hh:nn:ss';
  TemplateName = 'Collection';

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
var
  RelativeFileName: string;
begin
  try
    if TPath.IsRelativePath(AFileName) then
      RelativeFileName := AFileName
    else
      RelativeFileName := ExtractRelativePath(FCurrentCollection.Path, AFileName);

    FDConnection.ExecSQL(FDQuery_InsertBook.SQL.Text,
      [FCurrentCollection.ID, RelativeFileName,
      AInfo.GetValue(0), AInfo.GetValue(1), AInfo.GetValue(2), AInfo.GetValue(3), AInfo.GetValue(4),
      AInfo.GetValue(5), AInfo.GetValue(6), AInfo.GetValue(7), AInfo.GetValue(8), AInfo.GetValue(9),
      AInfo.GetValue(10), AInfo.GetValue(11), AInfo.GetValue(12), AInfo.GetValue(13), AInfo.GetValue(14)]
    );
  except
    on E: Exception do
    begin
      Log.Error('AddPublicationInfo: ' + E.Message, TagMain);
      raise;
    end;
  end;
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
  FCurrentCollection := Default(TBookCollection);
  Setup;
end;

procedure TDatabase.BeforeDestruction;
begin
  Teardown;
  inherited BeforeDestruction;
end;

procedure TDatabase.BeginUpdateCollection(const APath: string);
begin
  if FCurrentCollection.Path <> APath then
    FCurrentCollection := CreateCollection(APath);
end;

function TDatabase.CreateCollection(const APath: string): TBookCollection;
const
  SQLInsert = 'insert into collection (name, created) values (''dummy'', datetime()) returning id';
  SQLUpdate = 'update collection set name = :name, root_path = :path';
var
  DS: TDataSet;
begin
  DS := TFDMemTable.Create(nil);
  try
    FDConnection.ExecSQL(SQLInsert, DS);
    Result.ID := DS.Fields[0].AsInteger;
    Result.Path := APath;
    try
      Result.Name := TemplateName + FCurrentCollection.ID.ToString;
      FDConnection.ExecSQL(SQLUpdate, [Result.Name, APath]);
      Log.Info(Format(TLogTemplates.CollectionCreated, [Result.Name]), TagMain);
    except
      on E: Exception do
      begin
        Log.Error('CreateCollection: ' + E.Message, TagMain);
        raise;
      end;
    end;
  finally
    DS.Free;
  end;
end;

procedure TDatabase.CreateDatabase;
begin
  try
    FDQuery_CreateTables.ExecSQL;
    Log.Info(Format(TLogTemplates.TablesCreated, []), TagMain);
  except
    on E: Exception do
      Log.Error('CreateDatabase: ' + E.Message, TagMain);
  end;
end;

function TDatabase.GetLastCollection: TBookCollection;
const
  SQL = 'select id, name, root_path from collection order by created desc limit 1';
var
  DS: TDataSet;
  Count: LongInt;
begin
  try
    Count := 0;
    DS := TFDMemTable.Create(nil);
    try
      Count := FDConnection.ExecSQL(SQL, DS);
    except
      on E: Exception do
        Log.Error('GetLastCollection: ' + E.Message, TagMain);
    end;

    if Count = 1 then
    begin
      Result.ID := DS.Fields[0].AsInteger;
      Result.Name := DS.Fields[1].AsString;
      Result.Path := DS.Fields[2].AsString;
    end;
  finally
    DS.Free;
  end;
end;

procedure TDatabase.ReadEnvironment;
var
  Ver: Variant;
begin
  Ver := FDConnection.ExecSQLScalar('select sqlite_version()');
  FSQLiteVersion := VarToStr(Ver);
  Log.Info('SQLite ' + FSQLiteVersion, TagMain);
end;

procedure TDatabase.Setup;
var
  DbExists: Boolean;
begin
  // 'C:\Users\Администратор\OneDrive\Документы\'
  FDbFileName := TPath.Combine(TOptions.GetDocumentsPath, DbName);
  DbExists := TFile.Exists(DbFileName);

  FDConnection.DriverName := S_FD_SQLiteId;
  FDConnection.LoginPrompt := False;
  FDConnection.Params.Values[S_FD_ConnParam_Common_Database] := FDbFileName;
{$IFDEF ANDROID}
  FDConnection.Params.Values[S_FD_ConnParam_SQLite_LockingMode] := S_FD_Exclusive;
{$ELSE}
  FDConnection.Params.Values[S_FD_ConnParam_SQLite_LockingMode] := S_FD_Normal;
{$ENDIF}
  FDConnection.Connected := True;
  Log.Info(TLogTemplates.DatabaseOpen, [FDbFileName], TagMain);
  ReadEnvironment;

  if DbExists then
    FCurrentCollection := GetLastCollection
  else
    CreateDatabase;
end;

procedure TDatabase.Teardown;
begin
  FDConnection.Connected := False;
end;

{ TBookCollection }

function TBookCollection.Assigned: Boolean;
begin
  Result := Name <> '';
end;

end.
