program LookBook;

uses
  Vcl.Forms,
  TestForm in 'TestForm.pas' {Form14},
  LookBook.Engine in 'Core\LookBook.Engine.pas',
  LookBook.Interfaces in 'Core\LookBook.Interfaces.pas',
  LookBook.Classes in 'Core\LookBook.Classes.pas',
  LookBook.Epub in 'Core\LookBook.Epub.pas',
  LookBook.Consts in 'Core\LookBook.Consts.pas',
  LookBook.Data in 'Data\LookBook.Data.pas' {Database: TDataModule},
  LookBook.Options in 'Core\LookBook.Options.pas',
  LookBook.Common in 'LookBook.Common.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm14, Form14);
  Application.CreateForm(TDatabase, Database);
  Application.Run;
end.
