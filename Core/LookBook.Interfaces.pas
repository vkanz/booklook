unit LookBook.Interfaces;

interface

uses LookBook.Common;

type
  ILogger = interface
    procedure Log(const AMessage: string);
  end;

type
  IBookReader = interface
    function Inspect(const AFileName: string): Boolean;
  end;

type
  IPublicationInfoConsumer = interface
    procedure AddPublicationInfo(const AFileName: string; const AInfo: TPublicationInfo);
  end;

type
  IDatabase = interface
    procedure Add(AInfo: TPublicationInfo);
  end;

implementation

end.
