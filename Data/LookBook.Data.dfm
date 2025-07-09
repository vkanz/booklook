object Database: TDatabase
  Height = 271
  Width = 425
  object FDConnection: TFDConnection
    Params.Strings = (
      
        'Database=C:\_Projects\Mazitov.StartST\Shturman\ShturmanRestClien' +
        't\Database\rest_client_db.s3db'
      'LockingMode=Normal'
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 72
    Top = 56
  end
  object FDQuery_CreateTables: TFDQuery
    Connection = FDConnection
    SQL.Strings = (
      'create table book ('
      '  file_name text,'
      '  title text,'
      '  language text,'
      '  identifier text,'
      '  creator text,'
      '  contributor text,'
      '  publisher text,'
      '  subject text,'
      '  description text,'
      '  date text,'
      '  type text,'
      '  format text,'
      '  source text,'
      '  relation text,'
      '  coverage text,'
      '  right text'
      '  );')
    Left = 224
    Top = 56
  end
  object FDQuery_InsertBook: TFDQuery
    Connection = FDConnection
    SQL.Strings = (
      'insert into book'
      '  (file_name,'
      '  title, language, identifier, creator, contributor,'
      '  publisher, subject, description, date, type,'
      '  format, source, relation, coverage, right)'
      'values'
      '  (:file_name,'
      '  :title, :language, :identifier, :creator, :contributor,'
      '  :publisher, :subject, :description, :date, :type,'
      '  :format, :source, :relation, :coverage, :right);')
    Left = 224
    Top = 120
    ParamData = <
      item
        Name = 'FILE_NAME'
        FDDataType = dtWideString
        ParamType = ptInput
      end
      item
        Name = 'TITLE'
        FDDataType = dtWideString
        ParamType = ptInput
      end
      item
        Name = 'LANGUAGE'
        FDDataType = dtWideString
        ParamType = ptInput
      end
      item
        Name = 'IDENTIFIER'
        FDDataType = dtWideString
        ParamType = ptInput
      end
      item
        Name = 'CREATOR'
        FDDataType = dtWideString
        ParamType = ptInput
      end
      item
        Name = 'CONTRIBUTOR'
        FDDataType = dtWideString
        ParamType = ptInput
      end
      item
        Name = 'PUBLISHER'
        FDDataType = dtWideString
        ParamType = ptInput
      end
      item
        Name = 'SUBJECT'
        FDDataType = dtWideString
        ParamType = ptInput
      end
      item
        Name = 'DESCRIPTION'
        FDDataType = dtWideString
        ParamType = ptInput
      end
      item
        Name = 'DATE'
        FDDataType = dtWideString
        ParamType = ptInput
      end
      item
        Name = 'TYPE'
        FDDataType = dtWideString
        ParamType = ptInput
      end
      item
        Name = 'FORMAT'
        FDDataType = dtWideString
        ParamType = ptInput
      end
      item
        Name = 'SOURCE'
        FDDataType = dtWideString
        ParamType = ptInput
      end
      item
        Name = 'RELATION'
        FDDataType = dtWideString
        ParamType = ptInput
      end
      item
        Name = 'COVERAGE'
        FDDataType = dtWideString
        ParamType = ptInput
      end
      item
        Name = 'RIGHT'
        FDDataType = dtWideString
        ParamType = ptInput
      end>
  end
end
