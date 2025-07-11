unit LookBook.Interfaces;

interface

uses LookBook.Common;

type
  IBookReader = interface
    function Inspect(const AFileName: string): Boolean;
  end;

type
  IPublicationInfoConsumer = interface
    procedure AddPublicationInfo(const AFileName: string; const AInfo: TPublicationInfo);
    procedure BeginUpdateCollection(const APath: string);
  end;

type
  IDatabase = interface
    procedure Add(AInfo: TPublicationInfo);
  end;

implementation

end.
