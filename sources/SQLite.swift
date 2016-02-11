import Foundation
import SQLite

class SwiftSQLite {
  var dbName:String = ""
  var tableName:String = ""

  var columns:[String] = []
  var results:[String:String] = [:]

  var nullValues:[String] = []
  var values:[String:String] = [:]
  var nullWheres:[String] = []
  var wheres:[String:String] = [:]

  func setDb(database:String) -> Void {
    self.dbName = database + ".db"
  }

  func setTable(table:String) -> Void {
    self.tableName = table
  }

  func stripComma(sql:String) -> String {
    var newSql = sql
    
    let range = newSql.endIndex.advancedBy(-1)..<newSql.endIndex
    newSql.removeRange(range)

    return newSql
  }
}

// MARK: Columns
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
}

// MARK: Create
extension SwiftSQLite {
  // Create Table
  func createTable() -> Bool {
    if self.columns.count >= 1 {
      var sql:String = "CREATE TABLE IF NOT EXISTS \(self.tableName) ("

      for column in self.columns {
        sql += "\(column),"
      }

      print("PreSub: \(sql)")

      let range = sql.endIndex.advancedBy(-1)..<sql.endIndex
      sql.removeRange(range)

      print("PostSub: \(sql)")

      return createTable(sql)
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
}

// MARK: Execute
extension SwiftSQLite {
  // Execute
  func execute(sql:String) -> Bool {
    // Make sure there is a db set
    guard self.dbName.characters.count > 0 else { return false }

    // Errors
    var errorPointer:UnsafeMutablePointer<Int8> = nil
    var error:String = ""

    // Connect
    var dbPointer:COpaquePointer = nil
    var iConnection:Int32
    iConnection = sqlite3_open(self.dbName, &dbPointer)
    if iConnection != 0 {
      print("Error: \(sqlite3_errmsg(dbPointer))")
    }

    // Callback
    

    // Execute
    var executeStatus:Int32
    //executeStatus = sqlite3_exec(dbPointer, sql, self.setResult, nil, &errorPointer)
    executeStatus = sqlite3_exec(dbPointer, sql, nil, nil, &errorPointer)
    if executeStatus != 0 {
      print("Error: \(errorPointer)")
      sqlite3_free(errorPointer)
      sqlite3_close(dbPointer)

      return false
    }

    sqlite3_close(dbPointer)

    return true
  }

  // Set Result
  func setResult(object:UnsafeMutablePointer<Void>, argc:Int32, argv:UnsafeMutablePointer<UnsafeMutablePointer<Int8>>, column:UnsafeMutablePointer<UnsafeMutablePointer<Int8>>) -> Int32 {
    var result:[String:String] = [:]
    /**
    for index in 0...(argv.count - 1) {
      result[column[index]] = argv[index] ? argv[index] : "NULL"
    }

    if result.count > 0 {
      self.results = result
    }
    */

    return 0
  }

  func getResult() -> [String:String] {
    return self.results
  }

  func destroyDatabase() -> Bool {
    return false
  }
}

func setResult(object:UnsafeMutablePointer<Void>, argc:Int32, argv:UnsafeMutablePointer<UnsafeMutablePointer<Int8>>, column:UnsafeMutablePointer<UnsafeMutablePointer<Int8>>) -> Int32 {
    return 0
}

// MARK: ORM
extension SwiftSQLite {
    func setColumn(column:String) -> Void {
        return setValue(column)
    }
    
    // Update NULL Values
    func setValue(column:String) -> Void {
        self.nullValues.append(column)
    
        return
    }

    // Update Values
    func setValue(column:String, value:Int) -> Void {
        return setValue(column, value: "\(value)")
    }
    func setValue(column:String, value:Float) -> Void {
        return setValue(column, value: "\(value)")
    }
    func setValue(column:String, value:Bool) -> Void {
        var valueString = "FALSE"
        if value {
            valueString = "TRUE"
        }

        return setValue(column, value: valueString)
    }
    func setValue(column:String, value:String) -> Void {
        self.values[column] = value
        
        return
    }
    
    // NULL Where
    func setWhere(column:String) -> Void {
        self.nullWheres.append(column)
        
        return
    }
    
    // Wheres
    func setWhere(column:String, value:Int) -> Void {
        return setWhere(column, value: "\(value)")
    }
    func setWhere(column:String, value:Float) -> Void {
        return setWhere(column, value: "\(value)")
    }
    func setWhere(column:String, value:Bool) -> Void {
        var valueString = "FALSE"
        if value {
            valueString = "TRUE"
        }

        return setWhere(column, value: valueString)
    }
    func setWhere(column:String, value:String) -> Void {
        self.wheres[column] = value
    
        return
    }

    // Update
    func update() -> Void {
        guard self.values.count != 0 else { return }

        var sql:String = "UPDATE \(self.tableName) SET "
        
        // Values with value
        for (column, value) in self.values {
            sql += "\(column) = '\(value)',"
        }

        // Null Vaues
        for value in self.nullValues {
            sql += "\(value) = NULL,"
        }

        // Remove the extra ,
        sql = stripComma(sql)

        // Add a space
        sql += " "

        // Where
        if self.wheres.count >= 1 {
            var i = 0
            for (column, value) in self.wheres {
                // skip the first one
                if i == 0 { 
                    sql += " WHERE \(column) = '\(value)' "

                    i += 1
                } else {
                    sql += " AND \(column) = '\(value)' "
                }
            }
        }

        //NULL Where
        if self.nullWheres.count >= 1 {
            var i = 0
            for value in self.nullWheres {
                if i == 0 {
                    if self.wheres.count >= 1 {
                        sql += " AND \(value)  = NULL " 
                    } else {
                        sql += " WHERE \(value) = NULL " 
                    }

                    i += 1
                } else {
                    sql += " AND \(value) = NULL "
                }
            }
        }

        // Close query
        sql += ";"
        
        return update(sql)
    }
    func update(sql:String) -> Void {
        self.wheres = [:]
        self.nullWheres = []
        self.values = [:]
        self.nullValues = []

        execute(sql)

        return
    }

    // Insert
    func insert() -> Void {
        guard self.values.count > 0 else { return }

        var sql:String = "INSERT INTO \(self.tableName) ("

        // Value Columns
        for (column, _) in self.values {
            sql += "\(column),"
        }

        // NULL Value Columns
        for value in self.nullValues {
            sql += "\(value),"
        }

        // Strip the extra ,
        sql = stripComma(sql)

        // End the columns
        sql += ") VALUES ("
        
        // Add Values
        for (_, value) in self.values {
            sql += "'\(value)',"
        }

        // Add NULL Values
        for _ in self.nullValues {
            sql += "NULL,"
        }        
        
        // Strip the extra ,
        sql = stripComma(sql)
        
        // Close query
        sql += ");"

        return insert(sql)
    }
    func insert(sql:String) -> Void {
        self.wheres = [:]
        self.nullWheres = []
        self.values = [:]
        self.nullValues = []

        execute(sql)

        return
    }

    // Delete
    func del() -> Void {
        var sql:String = ""

        // NULL Values


        return del(sql)
    }
    func del(sql:String) -> Void {
        self.wheres = [:]
        self.nullWheres = []
        self.values = [:]
        self.nullWheres = []

        execute(sql)
        
        return
    }

    // Select all from table
    func selectAllFromTable(table:String) -> Void {
       return select("SELECT * FROM \(table)") 
    }

    // Select
    func select() -> Void {
        return select("")
    }
    func select(sql:String) -> Void {
        self.wheres = [:]
        self.nullWheres = []
        self.values = [:]
        self.nullValues = []

        execute(sql)
        
        return
    }
}
