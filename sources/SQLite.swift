import SQLite

class SwiftSQLite {
  var dbName:String = ""
  var tableName:String = ""

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
      column = "\(name) BLOB NULL"
    } else {
      column = "\(name) BLOB NOT NULL"
    }

    return addColumn(column)
  }

  // Blob


  func connect(database: String) -> Void {
    var dbPointer:COpaquePointer = nil
    var iConnection:Int32
    iConnection = sqlite3_open(database, &dbPointer)
    if iConnection != 0 {
      print("Error: \(sqlite3_errmsg(dbPointer))")
    } else {
      print("Connected")
    }
  }
}
