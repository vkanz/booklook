unit LookBook.Options;

interface

type
  TOptions = class
  public
    class function GetDocumentsPath: string;
  end;

implementation

uses IOUtils;

{ TOptions }

class function TOptions.GetDocumentsPath: string;
begin
  Result := TPath.GetDocumentsPath;
end;

end.
