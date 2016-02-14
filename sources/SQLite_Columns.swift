import Foundation

import SQLite

extension SwiftSQLite {
  // Int columns
  func addPrimary(name:String) -> Void {
    return addInt(name, length: 8, nullable: false, index: false, primary: true)
  }
  func addInt(name:String) -> Void {
    return addInt(name, length: 8, nullable: false, index: false, primary: false)
  }
  func addInt(name:String, length:Int) -> Void {
    return addInt(name, length: length, nullable: false, index: false, primary: false)
  }
  func addInt(name:String, length:Int, nullable:Bool) -> Void {
    return addInt(name, length: length, nullable: nullable, index: false, primary: false)
  }
  func addInt(name:String, length:Int, nullable:Bool, index:Bool) -> Void {
    return addInt(name, length: length, nullable: nullable, index: index, primary: false)
  }
  func addInt(name:String, length:Int, nullable:Bool, index:Bool, primary:Bool) -> Void {
    var column:String = ""

    if index {
      column = "\(name) INTEGER(\(length)) INDEX NOT NULL"
    } else {
      if primary {
        column = "\(name) INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL"
      } else {
        if nullable {
          column = "\(name) INTEGER(\(length)) NULL"
        } else {
          column = "\(name) INTEGER(\(length)) NOT NULL"
        }
      }
    }

    return addColumn(column)
  }

  // Char
  func addChar(name:String) -> Void {
    return addChar(name, length: 100, nullable: false)
  }
  func addChar(name:String, nullable:Bool) -> Void {
    return addChar(name, length: 100, nullable: nullable)
  }
  func addChar(name:String, length:Int, nullable:Bool) {
    var column:String = ""

    if nullable {
      column = "\(name) CHAR(\(length)) NULL"
    } else {
      column = "\(name) CHAR(\(length)) NOT NULL"
    }

    return addColumn(column)
  }

  // Text
  func addText(name:String) -> Void {
    return addText(name, nullable: false)
  }
  func addText(name:String, nullable:Bool) -> Void {
    var column:String = ""

    if nullable {
      column = "\(name) TEXT NULL"
    } else {
      column = "\(name) TEXT NOT NULL"
    }

    return addColumn(column)
  }

  // Real
  func addReal(name:String) -> Void {
    return addReal(name, nullable: false)
  }
  func addReal(name:String, nullable:Bool) -> Void {
    var column:String = ""

    if nullable {
      column = "\(name) REAL NULL"
    } else {
      column = "\(name) REAL NOT NULL"
    }

    return addColumn(column)
  }

  // Blob
  func addBlob(name:String) -> Void {
    return addBlob(name, nullable: false)
  }
  func addBlob(name:String, nullable:Bool) -> Void {
    var column:String = ""

    if nullable {
      column = "\(name) BLOB NULL"
    } else {
      column = "\(name) BLOB NOT NULL"
    }

    return addColumn(column)
  }

  // Bool
  func addBool(name:String) -> Void {
    return addBool(name, index: false, nullable: false)
  }
  func addBool(name:String, index:Bool) -> Void {
    return addBool(name, index: index, nullable: false)
  }
  func addBool(name:String, index:Bool, nullable:Bool) -> Void {
    return addInt(name, length: 1, nullable: nullable, index: index)
  }

  // Date
  func addDate(name:String) -> Void {
    return addDate(name, nullable: false)
  }
  func addDate(name:String, nullable:Bool) -> Void {
    return addText(name, nullable: nullable)
  }

  // Add Column
  func addColumn(column:String) -> Void {
    guard self.tableName.characters.count > 0 else { return }
    guard self.dbName.characters.count > 0 else { return }

    self.columns.append(column)

    return
  }

  // Types of column
  func getColumnType(index:CInt, statement:COpaquePointer) -> CInt {
    var type:CInt = 0

    let blobTypes = ["Binary", "BLOB", "VARBINARY"]
    let charTypes = ["CHAR", "CHARACTER", "CLOB", "NATIONAL VARYING CHARACTER", "NATIVE CHARACTER", "NCHAR", "NVARCHAR", "TEXT", "VARCHAR", "VARIANT", "VARYING CHARACTER"]
    let dateTypes = ["DATE", "DATETIME", "TIME", "TIMESTAMP"]
    let intTypes  = ["BIGINT", "BIT", "BOOL", "BOOLEAN", "INT", "INT2", "INT8", "INTEGER", "MEDIUMINT", "SMALLIHT", "TINYINT"]
    let nullTypes = ["NULL"]
    let realTypes = ["DECIMAL", "DOUBLE", "DOUBLE PRECISION", "FLOAT", "NUMERIC", "REAL"]

    let buffer = sqlite3_column_decltype(statement, index)
    if buffer != nil {
      let temp = String.fromCString(buffer)!.uppercaseString

      // remove parenthesis
      let preParent = temp
      preParent.rangeOfString("(")!.startIndex
      print(preParent)

      //let preParent = temp[temp.startIndex..<find(temp, "(")!]

      // Integer
      if intTypes.contains(preParent) {
        return SQLITE_INTEGER
      }

      // Real
      if realTypes.contains(preParent) {
        return SQLITE_FLOAT
      }

      // Char
      if charTypes.contains(preParent) {
        return SQLITE_TEXT
      }

      // Blob
      if blobTypes.contains(preParent) {
        return SQLITE_BLOB
      }

      // NULL
      if nullTypes.contains(preParent) {
        return SQLITE_NULL
      }

      // Date
      if dateTypes.contains(preParent) {
        return SQLITE_DATE
      }

      // Text
      return SQLITE_TEXT
    } else {
      type = sqlite3_column_type(statement, index)
    }

    return type
  }

  // Column Values
  func getColumnValue(index:CInt, type:CInt, statement:COpaquePointer) -> AnyObject? {
    // Integer
    if type == SQLITE_INTEGER {
      return Int(sqlite3_column_int(statement, index)) as? AnyObject
    }

    // Float
    if type == SQLITE_FLOAT {
      return Double(sqlite3_column_double(statement, index)) as? AnyObject
    }

    // Blob
    if type == SQLITE_BLOB {
      let data = sqlite3_column_blob(statement, index)
      let size = sqlite3_column_bytes(statement, index)
      return NSData(bytes: data, length: Int(size))
    }

    // NULL
    if type == SQLITE_NULL {
      return nil
    }

    // Date
    if type == SQLITE_DATE {
      let text = UnsafePointer<Int8>(sqlite3_column_text(statement, index))
      if text != nil {
        if let buffer = String.fromCString(text) {
          let dateFormatter = NSDateFormatter()
          dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
          let value = dateFormatter.dateFromString(buffer)

          return value
        }
      }

      let value     = sqlite3_column_double(statement, index)
      let dateTime  = NSDate(timeIntervalSince1970: value)

      return dateTime
    }

    // String
    let buffer  = UnsafePointer<Int8>(sqlite3_column_text(statement, index))
    let value   = String.fromCString(buffer)

    return value as? AnyObject
  }
}
