unit LookBook.Epub;

interface

uses
  System.Zip, Classes,
  Generics.Collections,
  LookBook.Common,
  LookBook.Interfaces,
  LookBook.Classes;

type
  TEpubContent = class
  const
    Package = 'package';
    Metadata = 'metadata';
    DC = 'dc';
  end;

const
  Terms: array[0..TermCount - 1] of string = (
  'title',
  'language', // — use a RFC3066 language code
  'identifier', // — use a probably unique string: URI or ISBN would be good
  'creator',
  'contributor',
  'publisher',
  'subject',
  'description',
  'date',
  'type',
  'format',
  'source',
  'relation',
  'coverage',
  'rights'
  );

type
  TEpubReader = class(TBookReader, IBookReader)
  private const
    ContentFileName = 'content.opf';
  private
    FZipFile: TZipFile;
    FValues: TStrings;
    function ExtractContent(const AFileName: string; out AContentFileName: string): Boolean;
    function ReadPublicationInformation(const AFileName: string): TPublicationInfo;
  public
    {IBookReader}
    function Inspect(const AFileName: string): Boolean;
    {}
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  end;

implementation

uses
  IOUtils, SysUtils,
  Xml.XMLDoc, Xml.XMLIntf, Xml.omnixmldom,
  LookBook.Logger,
  LookBook.Consts;

const
  LogTag = TagMain; //'epub';

{ TEpubReader }

procedure TEpubReader.AfterConstruction;
begin
  inherited AfterConstruction;
  FZipFile := TZipFile.Create;
  FValues:= TStringList.Create;
end;

procedure TEpubReader.BeforeDestruction;
begin
  inherited BeforeDestruction;
  FValues.Free;
  FZipFile.Free;
end;

function TEpubReader.ExtractContent(const AFileName: string; out AContentFileName: string): Boolean;
var
  TempDir: string;
  UnzipFileName: string;
begin
  AContentFileName := string.Empty;

  //Unzip to TempDir
  TempDir := TPath.Combine(TPath.GetTempPath, AppID);
  if TDirectory.Exists(TempDir) then
    TDirectory.Delete(TempDir, True);
  TDirectory.CreateDirectory(TempDir);
  UnzipFileName := TPath.Combine(TempDir, ContentFileName);
  if TFile.Exists(UnzipFileName) then
    TFile.Delete(UnzipFileName);

  //Find content and unzip
  FZipFile.Open(AFileName, TZipMode.zmRead);
  try
    for var I := Low(FZipFile.FileNames) to High(FZipFile.FileNames) do
    begin
      if TPath.GetFileName(FZipFile.FileNames[I]) = ContentFileName then
      begin
        FZipFile.Extract(I, TempDir, False);
        AContentFileName := TPath.Combine(TempDir, ContentFileName);
        Break;
      end;
    end;

    Result := AContentFileName <> string.Empty;
    if not Result then
      Log.Error(TLogTemplates.FileNotFound, [ContentFileName], LogTag);

  finally
    FZipFile.Close;
  end;
end;

function TEpubReader.Inspect(const AFileName: string): Boolean;
var
  UnzipFileName: string;
  PublicationInfo: TPublicationInfo;
begin
  Log.Info(TLogTemplates.Book, [TPath.GetFileName(AFileName)], LogTag);

  Result := ExtractContent(AFileName, UnzipFileName);
  if Result then
  begin
    PublicationInfo := ReadPublicationInformation(UnzipFileName);
    Log.Info('Info: ' + PublicationInfo.ToJSON, LogTag);
    Assert(Assigned(FPublicationInfoConsumer));
    FPublicationInfoConsumer.AddPublicationInfo(AFileName, PublicationInfo);
  end
  else
    Log.Error(TLogTemplates.FileNotFound, [ContentFileName], LogTag);
end;

function TEpubReader.ReadPublicationInformation(const AFileName: string): TPublicationInfo;
var
  XmlDoc: IXMLDocument;
  NodePackage,
  NodeMeta: IXMLNode;
  NameSpaceURI,
  NameSpaceDC: string;
begin
  if not FileExists(AFileName) then
  begin
    Log.Error(TLogTemplates.FileNotFound, [AFileName], LogTag);
    Exit;
  end;

  try
    XmlDoc := TXMLDocument.Create(nil);
    TXMLDocument(XmlDoc).DOMVendor := OmniXML4Factory;
    XmlDoc.LoadFromFile(AFileName);

    { Root node; namespace "xmlns" }
    NodePackage := XmlDoc.ChildNodes.FindNode(TEpubContent.Package);
    if NodePackage = nil then
    begin
      Log.Error(TLogTemplates.NodeNotFound, [TEpubContent.Package], LogTag);
      Exit;
    end;
    if NodePackage.HasAttribute('xmlns') then
      NameSpaceURI := NodePackage.Attributes['xmlns']
    else
      NameSpaceURI := 'http://www.idpf.org/2007/opf';

    { Node "metadata"; namespace "xmlns:dc" }
    NodeMeta := NodePackage.ChildNodes.FindNode(TEpubContent.Metadata);
    if NodeMeta = nil then
    begin
      Log.Info(TLogTemplates.NodeNotFound, [TEpubContent.Metadata], LogTag);
      Exit;
    end;
    if NodeMeta.HasAttribute(TEpubContent.DC, NameSpaceURI) then
      NameSpaceDC := NodeMeta.GetAttributeNS(TEpubContent.DC, NameSpaceURI)
    else
      NameSpaceDC := 'http://purl.org/dc/elements/1.1/';

    { Publication information }
    FValues.Clear;
    for var I := 0 to TermCount - 1 do
    begin
      var TheNode: IXMLNode := NodeMeta.ChildNodes.FindNode(Terms[I], NameSpaceDC);
      var NodeValue: string := string.Empty;
      if Assigned(TheNode) then
        FValues.Add(TheNode.NodeValue)
      else
        FValues.Add(string.Empty);
    end;

    Result.AssignStrings(FValues);
  except
    Log.Error(TLogTemplates.BadXml, [TPath.GetFileName(AFileName)], LogTag);
  end;
end;

end.
