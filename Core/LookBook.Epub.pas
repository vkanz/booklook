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
    procedure Log(const AFormat: string; const AArgs: array of const);
    function GetTargetDirectory: string;
    function ExtractContent(const AFileName: string; out AContentFileName: string): Boolean;
    procedure ReadPublicationInformation(const AFileName: string);
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
  LookBook.Consts;

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

  //Place to unzip
  TempDir := TPath.Combine(TPath.GetTempPath, AppID);
  if not TDirectory.Exists(TempDir) then
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
      Log(TLogTemplates.FileNotFound, [ContentFileName]);

  finally
    FZipFile.Close;
  end;
end;

function TEpubReader.GetTargetDirectory: string;
begin
  Result := TPath.Combine(TPath.GetTempPath, AppID);
  if TDirectory.Exists(Result) then
  begin
    //Clear directory
    TDirectory.Delete(Result, True);
    TDirectory.CreateDirectory(Result);
  end
  else
    TDirectory.CreateDirectory(Result);
end;

function TEpubReader.Inspect(const AFileName: string): Boolean;
var
  UnzipFileName: string;
begin
  Log(TLogTemplates.Book, [TPath.GetFileNameWithoutExtension(AFileName)]);

  Result := ExtractContent(AFileName, UnzipFileName);
  if Result then
    ReadPublicationInformation(UnzipFileName)
  else
    Log(TLogTemplates.FileNotFound, [ContentFileName]);
end;

procedure TEpubReader.Log(const AFormat: string; const AArgs: array of const);
begin
  Assert(Assigned(FLogger), 'Logger is not assigned');
  FLogger.Log(Format(AFormat, AArgs));
end;

procedure TEpubReader.ReadPublicationInformation(const AFileName: string);
var
  XmlDoc: IXMLDocument;
  NodePackage,
  NodeMeta,
  NodeTitle: IXMLNode;
  NameSpaceURI,
  NameSpaceDC: string;
begin
  if not FileExists(AFileName) then
  begin
    Log(TLogTemplates.FileNotFound, [AFileName]);
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
      Log(TLogTemplates.NodeNotFound, [TEpubContent.Package]);
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
      Log(TLogTemplates.NodeNotFound, [TEpubContent.Metadata]);
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
      begin
        NodeValue := TheNode.NodeValue;
        Log(TLogTemplates.Debug, [Terms[I] + '=' + NodeValue]);
      end;
      FValues.Add(NodeValue);
    end;

    Assert(Assigned(FPublicationInfoConsumer));
    FPublicationInfoConsumer.AddPublicationInfo(AFileName, TPublicationInfo.FromStrings(FValues));

  except
    Log(TLogTemplates.BadXml, [TPath.GetFileName(AFileName)]);
  end;
end;

end.
