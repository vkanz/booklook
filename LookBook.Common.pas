unit LookBook.Common;

interface

uses Classes;

const
  TermCount = 15;

type
  TPublicationInfo = record
    Title: string;        // 0
    Language: string;     // 1
    Identifier: string;   // 2
    Creator: string;      // 3
    Contributor: string;  // 4
    Publisher: string;    // 5
    Subject: string;      // 6
    Description: string;  // 7
    Date: string;         // 8
    Kind: string;         // 9 Type
    Format: string;       // 10
    Source: string;       // 11
    Relation: string;     // 12
    Coverage: string;     // 13
    Right: string;        // 14
    procedure SetValue(AIndex: Integer; const AValue: string);
    function GetValue(AIndex: Integer): string;
    procedure AssignStrings(AValues: TStrings);
    function ToJSON: string;
    class function FromStrings(AValues: TStrings): TPublicationInfo; static;
  end;

implementation

uses StrUtils;

{ TPublicationInfo }

procedure TPublicationInfo.AssignStrings(AValues: TStrings);
begin
  for var I := 0 to TermCount - 1 do
    SetValue(I, AValues[I]);
end;

class function TPublicationInfo.FromStrings(AValues: TStrings): TPublicationInfo;
begin
  Result.AssignStrings(AValues);
end;

function TPublicationInfo.GetValue(AIndex: Integer): string;
begin
  Assert((0 <= AIndex) and (AIndex < TermCount));

  case AIndex of
    0: Result := Title;
    1: Result := Language;
    2: Result := Identifier;
    3: Result := Creator;
    4: Result := Contributor;
    5: Result := Publisher;
    6: Result := Subject;
    7: Result := Description;
    8: Result := Date;
    9: Result := Kind;
    10: Result := Format;
    11: Result := Source;
    12: Result := Relation;
    13: Result := Coverage;
    14: Result := Right;
    else Result := '';
  end;
end;

procedure TPublicationInfo.SetValue(AIndex: Integer; const AValue: string);
begin
  Assert((0 <= AIndex) and (AIndex < TermCount));

  case AIndex of
    0: Title := AValue;
    1: Language := AValue;
    2: Identifier := AValue;
    3: Creator := AValue;
    4: Contributor := AValue;
    5: Publisher := AValue;
    6: Subject := AValue;
    7: Description := AValue;
    8: Date := AValue;
    9: Kind := AValue;
    10: Format := AValue;
    11: Source := AValue;
    12: Relation := AValue;
    13: Coverage := AValue;
    14: Right := AValue;
  end;
end;

function TPublicationInfo.ToJSON: string;
begin
  Result :=
    IfThen(Title = '', '', '"Title":"' + Title + '"') +
    IfThen(Language = '', '', ',"Language":"' + Language + '"') +
    IfThen(Identifier = '', '', ',"Identifier":"' + Identifier + '"') +
    IfThen(Creator = '', '', ',"Creator":"' + Creator + '"') +
    IfThen(Contributor = '', '', ',"Contributor":"' + Contributor + '"') +
    IfThen(Publisher = '', '', ',"Publisher":"' + Publisher + '"') +
    IfThen(Subject = '', '', ',"Subject":"' + Subject + '"') +
    IfThen(Description = '', '', ',"Description":"' + Description + '"') +
    IfThen(Date = '', '', ',"Date":"' + Date + '"') +
    IfThen(Kind = '', '', ',"Kind":"' + Kind + '"') +
    IfThen(Format = '', '', ',"Format":"' + Format + '"') +
    IfThen(Source = '', '', ',"Source":"' + Source + '"') +
    IfThen(Relation = '', '', ',"Relation":"' + Relation + '"') +
    IfThen(Coverage = '', '', ',"Coverage":"' + Coverage + '"') +
    IfThen(Right = '', '', ',"Right":"' + Right + '"');
  if Result[1] = ',' then
    Result := Copy(Result, 2, Length(Result));
  Result := '{' + Result + '}';
end;

end.
