unit TestForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  LookBook.Engine,
  LookBook.Interfaces,
  LookBook.Data,
  LookBook.Common;

type
  TForm14 = class(TForm)
    Edit1: TEdit;
    Button1: TButton;
    Memo1: TMemo;
    Edit_Database: TEdit;
    procedure Button1Click(Sender: TObject);
  private
    FLookBookEngine: TLookBookEngine;
    FDatabase: TDatabase;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    { ILogger }
    procedure Log(const AMessage: string);
  end;

var
  Form14: TForm14;

implementation

{$R *.dfm}

uses IOUtils;

procedure TForm14.AfterConstruction;
begin
  inherited AfterConstruction;
  FDatabase := TDatabase.Create(Self);
  FLookBookEngine := TLookBookEngine.Create(FDatabase);

  Edit_Database.Text := FDatabase.DbFileName;
end;

procedure TForm14.BeforeDestruction;
begin
  inherited;
  FLookBookEngine.Free;
end;

procedure TForm14.Button1Click(Sender: TObject);
var
  FileName: string;
begin
  FileName := TPath.GetFullPath(
  TPath.Combine(
    TPath.GetDirectoryName(ParamStr(0)),
    Edit1.Text));

  FLookBookEngine.ScanDirectory(FileName);
end;

procedure TForm14.Log(const AMessage: string);
begin
  Memo1.Lines.Add(AMessage);
  SendMessage(Memo1.Handle, WM_VSCROLL, SB_LINEDOWN, 0);
end;

end.
