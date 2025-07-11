program BookIndexCmd;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, IOUtils,
  LookBook.Center in 'App\LookBook.Center.pas',
  LookBook.Classes in 'Core\LookBook.Classes.pas',
  LookBook.Consts in 'Core\LookBook.Consts.pas',
  LookBook.Engine in 'Core\LookBook.Engine.pas',
  LookBook.Epub in 'Core\LookBook.Epub.pas',
  LookBook.Interfaces in 'Core\LookBook.Interfaces.pas',
  LookBook.Logger in 'Core\LookBook.Logger.pas',
  LookBook.Options in 'Core\LookBook.Options.pas',
  LookBook.Data in 'Data\LookBook.Data.pas' {Database: TDataModule};

var
  LookBookCenter: TLookBookCenter;
begin
  try
    try
      LookBookCenter := TLookBookCenter.Create;

    var FileName: string := TPath.GetFullPath(
      TPath.Combine(
        TPath.GetDirectoryName(ParamStr(0)),
        '..\..\Test\'));

      LookBookCenter.ScanDirectory(FileName);

      WriteLn('Press ENTER');
      ReadLn;

    finally
      LookBookCenter.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
