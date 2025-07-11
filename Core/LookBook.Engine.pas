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
    FPublicationInfoConsumer: IPublicationInfoConsumer;
    procedure CreateReaders;
  protected
    procedure ProcessBook(const AFileName: string);
  public
    constructor Create([weak]APublicationInfoConsumer: IPublicationInfoConsumer);
    destructor Destroy; override;
    procedure ScanDirectory(const ADirectoryName: string);
  end;

implementation

uses
  SysUtils, IOUtils,
  LookBook.Logger,
  LookBook.Classes,
  LookBook.Epub,
  LookBook.Consts;

{ TLookBookEngine }

constructor TLookBookEngine.Create([weak]APublicationInfoConsumer: IPublicationInfoConsumer);
begin
  FPublicationInfoConsumer := APublicationInfoConsumer;
  FReaders := TDictionary<string, IBookReader>.Create;
  CreateReaders;
end;

procedure TLookBookEngine.CreateReaders;
begin
  FReaders.Add(BookExtensions[TBookType.Epub], TEpubReader.Create(FPublicationInfoConsumer));
end;

destructor TLookBookEngine.Destroy;
begin
  FReaders.Free;
  inherited Destroy;
end;

procedure TLookBookEngine.ProcessBook(const AFileName: string);
var
  Ext: string;
begin
  Ext := TPath.GetExtension(AFileName);

  if not FReaders.ContainsKey(Ext) then
  begin
    Log.Warn(TLogTemplates.ExtNotFound, [Ext], TagMain);
    Exit;
  end;

  FReaders[Ext].Inspect(AFileName);
end;

procedure TLookBookEngine.ScanDirectory(const ADirectoryName: string);
var
  Files: TArray<string>;
begin
  FPublicationInfoConsumer.BeginUpdateCollection(ADirectoryName);

  Log.Info(TLogTemplates.ScanningStarted, [ADirectoryName], TagMain);

  Files := TDirectory.GetFiles(ADirectoryName, '*.*', TSearchOption.soAllDirectories);
  for var I := Low(Files) to High(Files) do
    ProcessBook(Files[I]);
    //Log(TLogTemplates.FileName, [TPath.GetFileName(Files[I])]);
end;

end.
