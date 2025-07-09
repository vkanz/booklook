unit LookBook.Engine;

interface

uses
  Generics.Collections,
  LookBook.Interfaces;

type
  TLookBookEngine = class
  private
    FReaders: TDictionary<string, IBookReader>;
    [weak]
    FLogger: ILogger;
    [weak]
    FPublicationInfoConsumer: IPublicationInfoConsumer;
    procedure CreateReaders;
  protected
    procedure Log(const AFormat: string; const AArgs: array of const);
    procedure ProcessBook(const AFileName: string);
  public
    constructor Create([weak]ALogger: ILogger; [weak]APublicationInfoConsumer: IPublicationInfoConsumer);
    destructor Destroy; override;
    procedure ScanDirectory(const ADirectoryName: string);
  end;

implementation

uses
  SysUtils, IOUtils,
  LookBook.Classes,
  LookBook.Epub,
  LookBook.Consts;

{ TLookBookEngine }

constructor TLookBookEngine.Create([weak]ALogger: ILogger; [weak]APublicationInfoConsumer: IPublicationInfoConsumer);
begin
  FLogger := ALogger;
  FPublicationInfoConsumer := APublicationInfoConsumer;
  FReaders := TDictionary<string, IBookReader>.Create;
  CreateReaders;
end;

procedure TLookBookEngine.CreateReaders;
begin
  FReaders.Add(BookExtensions[TBookType.Epub], TEpubReader.Create(FLogger, FPublicationInfoConsumer));
end;

destructor TLookBookEngine.Destroy;
begin
  FReaders.Free;
  inherited Destroy;
end;

procedure TLookBookEngine.Log(const AFormat: string; const AArgs: array of const);
begin
  Assert(Assigned(FLogger));
  FLogger.Log(Format(AFormat, AArgs));
end;

procedure TLookBookEngine.ProcessBook(const AFileName: string);
var
  Ext: string;
begin
  Ext := TPath.GetExtension(AFileName);

  if not FReaders.ContainsKey(Ext) then
  begin
    Log(TLogTemplates.ExtNotFound, [Ext]);
    Exit;
  end;

  FReaders[Ext].Inspect(AFileName);
end;

procedure TLookBookEngine.ScanDirectory(const ADirectoryName: string);
var
  Files: TArray<string>;
begin
  Log(TLogTemplates.ScanningStarted, [ADirectoryName]);

  Files := TDirectory.GetFiles(ADirectoryName);
  for var I := Low(Files) to High(Files) do
    ProcessBook(Files[I]);
    //Log(TLogTemplates.FileName, [TPath.GetFileName(Files[I])]);
end;

end.
