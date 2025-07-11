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
      '-- collection DDL'
      ''
      'CREATE TABLE collection ('
      #9'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'
      #9'name TEXT NOT NULL,'
      #9'created TEXT'
      ', root_path TEXT);'
      ''
      'CREATE UNIQUE INDEX collection_name_IDX ON collection (name);'
      ''
      '-- book DDL'
      ''
      'CREATE TABLE book ('
      #9'collection_id INTEGER NOT NULL,'
      #9'file_name TEXT,'
      #9'title TEXT,'
      #9'"language" TEXT,'
      #9'identifier TEXT,'
      #9'creator TEXT,'
      #9'contributor TEXT,'
      #9'publisher TEXT,'
      #9'subject TEXT,'
      #9'description TEXT,'
      #9'date TEXT,'
      #9'"type" TEXT,'
      #9'format TEXT,'
      #9'"source" TEXT,'
      #9'relation TEXT,'
      #9'coverage TEXT,'
      #9'"right" TEXT,'
      
        #9'CONSTRAINT book_collection_FK FOREIGN KEY (collection_id) REFER' +
        'ENCES collection(id)'
      ');'
      ''
      'CREATE INDEX book_collection_id_IDX ON book (collection_id);'
      'CREATE INDEX book_file_name_IDX ON book (file_name);')
    Left = 224
    Top = 56
  end
  object FDQuery_InsertBook: TFDQuery
    Connection = FDConnection
    SQL.Strings = (
      'insert into book'
      '  (collection_id, file_name,'
      '  title, language, identifier, creator, contributor,'
      '  publisher, subject, description, date, type,'
      '  format, source, relation, coverage, right)'
      'values'
      '  (:collection_id, :file_name,'
      '  :title, :language, :identifier, :creator, :contributor,'
      '  :publisher, :subject, :description, :date, :type,'
      '  :format, :source, :relation, :coverage, :right);')
    Left = 104
    Top = 152
    ParamData = <
      item
        Name = 'COLLECTION_ID'
        ParamType = ptInput
      end
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
