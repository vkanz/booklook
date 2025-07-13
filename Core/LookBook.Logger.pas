unit LookBook.Logger;

interface

uses
  LoggerPro;

var
  Log: ILogWriter;

const
  TagMain = 'main';

implementation

uses
  System.SysUtils,
  LoggerPro.FileAppender,
  LoggerPro.ConsoleAppender,
  LoggerPro.OutputDebugStringAppender;

{$DEFINE DMVC342}

type
  TLookBookConsoleAppender = class(TLoggerProConsoleAppender)
    constructor Create; override;
  end;

type
  TLogItemRenderer = class(TInterfacedObject, ILogItemRenderer)
    procedure Setup;
    procedure TearDown;
    function RenderLogItem(const aLogItem: TLogItem): String;
  end;

{ TLookBookConsoleAppender }

constructor TLookBookConsoleAppender.Create;
var
  TheFormatSettings: TFormatSettings;
begin
  inherited Create;
  OnLogRow := procedure(const LogItem: TLogItem; out LogRow: string)
    begin
      LogRow := Format('%s'#9'%s'#9'%s'#9'%s', [
        TimeToStr(LogItem.TimeStamp)
        ,LogItem.ThreadID.ToString
        ,LogItem.LogTypeAsString
        ,LogItem.LogMessage
        //,LogItem.LogTag
      ]);
    end;
end;

{ TLogItemRenderer }

function TLogItemRenderer.RenderLogItem(const aLogItem: TLogItem): String;
begin
  Result := TimeToStr(aLogItem.TimeStamp) + #9 +
    aLogItem.LogTypeAsString + #9 +
    aLogItem.LogMessage;
end;

procedure TLogItemRenderer.Setup;
begin

end;

procedure TLogItemRenderer.TearDown;
begin

end;

initialization
  Log := BuildLogWriter([
    TLoggerProFileAppender.Create(
      TLoggerProFileAppenderBase.DEFAULT_MAX_BACKUP_FILE_COUNT,
      TLoggerProFileAppenderBase.DEFAULT_MAX_FILE_SIZE_KB,
      '',
      TLoggerProFileAppenderBase.DEFAULT_FILENAME_FORMAT,
{$IFDEF DMVC342}
      TLogItemRenderer.Create(),
{$ELSE}
      TLogLayout.LOG_LAYOUT_3,
{$ENDIF}
      TEncoding.UTF8)
    //,TLoggerProOutputDebugStringAppender.Create
      ,TLookBookConsoleAppender.Create()
    ]);
  Log.Info('=== Start logging ===', TagMain);
finalization
  Log.Info('=== Stop logging ===', TagMain);
  Log := nil;
end.
