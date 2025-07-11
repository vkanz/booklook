unit LookBook.Center;

interface

uses
  LookBook.Engine,
  LookBook.Data;

type
  TLookBookCenter = class
  private
    FLookBookEngine: TLookBookEngine;
    FDatabase: TDatabase;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ScanDirectory(const ADirectoryName: string);
  end;

implementation

{ TLookBookCenter }

constructor TLookBookCenter.Create;
begin
  inherited Create;

  FDatabase := TDatabase.Create(nil);
  FLookBookEngine := TLookBookEngine.Create(FDatabase);
end;

destructor TLookBookCenter.Destroy;
begin
  FLookBookEngine.Free;
  FDatabase.Free;

  inherited Destroy;
end;

procedure TLookBookCenter.ScanDirectory(const ADirectoryName: string);
begin
  FLookBookEngine.ScanDirectory(ADirectoryName);
end;

end.
