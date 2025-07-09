unit LookBook.Classes;

interface

uses Classes,
  LookBook.Interfaces;

{$SCOPEDENUMS ON}

type
  TBookType = (
    Unknown,
    Epub
  );

const
  BookExtensions: array[TBookType] of string = (
    '',
    '.epub'
  );

type
  TBookMetaInformation = class
  private
    FName: string;
  public
    property Name: string read FName write FName;
  end;

type
  TBookReader = class(TInterfacedObject)
  protected
    FLogger: ILogger;
    FPublicationInfoConsumer: IPublicationInfoConsumer;
  public
    constructor Create(ALogger: ILogger; APublicationInfoConsumer: IPublicationInfoConsumer);
    destructor Destroy; override;
  end;

function ExtensionToBookType(const AValue: string): TBookType;

implementation

uses SysUtils;

function ExtensionToBookType(const AValue: string): TBookType;
begin
  Result := TBookType.Unknown;
  for var BT := Low(TBookType) to High(TBookType) do
    if SameText(AValue, BookExtensions[BT]) then
    begin
      Result := BT;
      Break;
    end;
end;

{ TBookReader }

constructor TBookReader.Create(ALogger: ILogger; APublicationInfoConsumer: IPublicationInfoConsumer);
begin
  FLogger := ALogger;
  FPublicationInfoConsumer := APublicationInfoConsumer;
end;

destructor TBookReader.Destroy;
begin
  FLogger := nil;
  inherited Destroy;
end;

end.
