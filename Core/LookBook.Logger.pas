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
  LoggerPro.OutputDebugStringAppender;

initialization
  Log := BuildLogWriter([TLoggerProFileAppender.Create(
      TLoggerProFileAppenderBase.DEFAULT_MAX_BACKUP_FILE_COUNT,
      TLoggerProFileAppenderBase.DEFAULT_MAX_FILE_SIZE_KB,
      '',
      TLoggerProFileAppenderBase.DEFAULT_FILENAME_FORMAT,
      TLogLayout.LOG_LAYOUT_3,
      TEncoding.UTF8)
    //,TLoggerProOutputDebugStringAppender.Create
    ]);
  Log.Info('=== Start logging ===', TagMain);
finalization
  Log.Info('=== Stop logging ===', TagMain);
  Log := nil;
end.
