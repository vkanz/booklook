unit LookBook.Consts;

interface

const
  AppID = '{139A260E-22EF-424C-B8B2-433C0878BB0B}';

type
  TLogTemplates = class
  const
    ScanningStarted = 'Scanning started: "%s"';
    Book = 'File: "%s"';
    FileName = 'File: "%s"';
    ExtNotFound = 'Unknown file extension "%s"';
    FileNotFound = 'Error: file "%s" not found';
    BadXml = 'Error: bad content "%s"';
    NodeNotFound = 'Error: node "%s" not found';
    Title = 'Title: "%s"';
    Debug = 'Debug: "%s"';
    DatabaseOpen = 'Database "%s" open';
    CollectionCreated = 'Collection "%s" created';
    TablesCreated = 'Tables created';
    CurrentCollection = 'Current collection: %d';
  end;

implementation

end.
