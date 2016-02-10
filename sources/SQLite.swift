import SQLite

class SwiftSQLite {
  var dbName:String = ""
  var tableName:String = ""
  var columns:[String] = []

  func setDb(database:String) -> Void {
    self.dbName = database + ".db"
  }

  func setTable(table:String) -> Void {
    self.tableName = table
  }

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
  func addChar(name:String, nullable:Bool, length:Int) {
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
    guard self.table.characters.count > 0 else { return }
    guard self.database.characters.count > 0 else { return }

    self.columns.append(column)

    return
  }

  // Create Table
  func createTable() -> Bool {
    if self.columns.size >= 1 {
      var sql:String = "CREATE TABLE IF NOT EXISTS \(self.table) ("

      for column in self.columns {
        sql += "\(column),"
      }

      var index = sql.endIndex.advanceBy(-1)
      var newSQL = sql.substringToIndex(index)

      return createTable(newSQL)
    }

    return false
  }
  func createTable(sql:String) -> Bool {
    return execute(sql)
  }

  // Create Index
  func addIndex(name:String) -> Void {
    return addIndex(name, column: name)
  }
  func addIndex(name:String, column:String) -> Void {
    return addIndex(name, column: column)
  }
  func addIndex(name:String, column:String, table:String) -> Void {
    let sql:String = "CREATE INDEX \(name) ON \(table) (\(column));"

    if execute(sql) == false {
      print("Index Failed")
    }

    return
  }

  // Execute
  func execute(sql:String) -> Bool {
    // Make sure there is a db set
    guard self.database.characters.count > 0 else { return false }

    // Errors
    var errorPointer:COpaquePointer = nil
    var error:String                = ""

    // Connect
    var dbPointer:COpaquePointer = nil
    var iConnection:Int32
    iConnection = sqlite3_open(self.database, &dbPointer)
    if iConnection != 0 {
      print("Error: \(sqlite3_errmsg(dbPointer))")
    }

    // Execute
    var iExecute:Int32
    iExecute = sqlite3_exec(dbPointer, sql, setResult, nil, &errorPointer)
    if iExecute != 0 {
      print("Error: \(errorPointer)")
      sqlite3_free(errorPointer)
      sqlite3_close(dbPointer)

      return false
    }

    sqlite3_close(dbPointer)

    return true
  }
}
