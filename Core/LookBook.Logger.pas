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

type
  TLookBookConsoleAppender = class(TLoggerProConsoleAppender)
    constructor Create;
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

initialization
  Log := BuildLogWriter([
    TLoggerProFileAppender.Create(
      TLoggerProFileAppenderBase.DEFAULT_MAX_BACKUP_FILE_COUNT,
      TLoggerProFileAppenderBase.DEFAULT_MAX_FILE_SIZE_KB,
      '',
      TLoggerProFileAppenderBase.DEFAULT_FILENAME_FORMAT,
      TLogLayout.LOG_LAYOUT_3,
      TEncoding.UTF8)
    //,TLoggerProOutputDebugStringAppender.Create
      ,TLookBookConsoleAppender.Create()
    ]);
  Log.Info('=== Start logging ===', TagMain);
finalization
  Log.Info('=== Stop logging ===', TagMain);
  Log := nil;
end.
