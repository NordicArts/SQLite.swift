import Foundation

import SQLite
import Echo

let SQLITE_DATE = SQLITE_NULL + 1
private let SQLITE_STATIC     = unsafeBitCast(0, sqlite3_destructor_type.self)
private let SQLITE_TRANSIENT  = unsafeBitCast(-1, sqlite3_destructor_type.self)

extension SwiftSQLite {
  // Execute
  func execute(sql:String, parameters:[AnyObject]? = nil) -> CInt {
    var result:CInt = 0
    dispatch_async(self.queuePointer) {
      let statement = self.prepare(sql, parameters: parameters)
      if statement != nil {
        result = self.execute(statement, sql:sql)
      }
    }

    return result
  }
  private func execute(statement:COpaquePointer, sql:String) -> CInt {
    var result = sqlite3_step(statement)

    // Step
    if (result != SQLITE_OK) && (result != SQLITE_DONE) {
      sqlite3_finalize(statement)
      if let error = String.fromCString(sqlite3_errmsg(self.dbPointer)) {
        let errorMessage = "SwiftSQLite - failed to execute SQL: \(sql), Error: \(error)"
        print(errorMessage)
      }

      return 0
    }

    // Type of Queries
    let upperCaseSQL = sql.uppercaseString
    if upperCaseSQL.hasPrefix("INSERT ") {
      let returnId = sqlite3_last_insert_rowid(self.dbPointer)

      result = CInt(returnId)
    } else if upperCaseSQL.hasPrefix("DELETE ") || upperCaseSQL.hasPrefix("UPDATE ") {
      var returnInt = sqlite3_changes(self.dbPointer)
      if returnInt == 0 {
        returnInt += 1
      }

      result = CInt(returnInt)
    } else {
      result = 1
    }

    // finalize
    sqlite3_finalize(statement)

    return result
  }

  // Query
  func query(sql:String, parameters:[AnyObject]? = nil) -> [[String:AnyObject]] {
    var rows = [[String:AnyObject]]()
    dispatch_async(self.queuePointer) {
      let statement = self.prepare(sql, parameters: parameters)
      if statement != nil {
        rows = self.query(statement, sql: sql)
      }
    }

    return rows
  }
  private func query(statement:COpaquePointer, sql:String) -> [[String:AnyObject]] {
    var rows              = [[String:AnyObject]]()
    var fetchColumnInfo   = true
    var columnCount:CInt  = 0
    var columnNames       = [String]()
    var columnTypes       = [CInt]()
    var result            = sqlite3_step(statement)
    while result == SQLITE_ROW {
      if fetchColumnInfo {
        columnCount = sqlite3_column_count(statement)
        for index in 0..<columnCount {
          let name = sqlite3_column_name(statement, index)
          columnNames.append(String.fromCString(name)!)
          columnTypes.append(self.getColumnType(index, statement: statement))
        }
        fetchColumnInfo = false
      }

      var row = [String:AnyObject]()
      for index in 0..<columnCount {
        let key   = columnNames[Int(index)]
        let type  = columnTypes[Int(index)]
        if let val = getColumnValue(index, type: type, statement: statement) {
          row[key] = val
        }
      }
      rows.append(row)

      result = sqlite3_step(statement)
    }
    sqlite3_finalize(statement)

    return rows
  }

  private func prepare(sql:String, parameters:[AnyObject]?) -> COpaquePointer {
    var statement:COpaquePointer  = nil
    let prepared                  = sql.cStringUsingEncoding(NSUTF8StringEncoding)
    let result                    = sqlite3_prepare_v2(self.dbPointer, prepared!, -1, &statement, nil)
    if result != SQLITE_OK {
      sqlite3_finalize(statement)
      if let error = String.fromCString(sqlite3_errmsg(self.dbPointer)) {
        let errorMessage = "SwiftSQLite - failed to prepare SQL: \(sql), Error: \(error)"
        print(errorMessage)
      }

      return nil
    }

    // Bind Parameters
    if parameters != nil {
      let parametersCount = sqlite3_bind_parameter_count(statement)
      let count           = CInt(parameters!.count)
      if parametersCount != count {
        let errorMessage = "SwiftSQLite - failed to bind parameters, counts don't match, SQL: \(sql), Parameters: \(parameters)"
        print(errorMessage)

        return nil
      }

      var flag:CInt = 0
      for index in 1...count {
        if let text = parameters![index - 1] as? String {
          flag = sqlite3_bind_text(statement, CInt(index), text, -1, SQLITE_TRANSIENT)
        } else if let data = parameters![index - 1] as? NSData {
          flag = sqlite3_bind_blob(statement, CInt(index), data.bytes, CInt(data.length), SQLITE_TRANSIENT)
        } else if let date = parameters![index - 1] as? NSDate {
          let text  = self.dateFormat.stringFromDate(date)
          flag      = sqlite3_bind_text(statement, CInt(index), text, -1, SQLITE_TRANSIENT)
        } else if let value = parameters![index - 1] as? Double {
          flag = sqlite3_bind_double(statement, CInt(index), CDouble(value))
        } else if let value = parameters![index - 1] as? Int {
          flag = sqlite3_bind_int(statement, CInt(index), CInt(value))
        } else {
          flag = sqlite3_bind_null(statement, CInt(index))
        }

        if flag != SQLITE_OK {
          sqlite3_finalize(statement)
          if let error = String.fromCString(sqlite3_errmsg(self.dbPointer)) {
            let errorMessage = "SwiftSQLite - failed to bind for SQL: \(sql), Parameters: \(parameters), Index: \(index), Error: \(error)"
            print(errorMessage)
          }

          return nil
        }
      }
    }

    return statement
  }

  func destroyDatabase() -> Bool {
    return false
  }

  private func closeDatabase() {
    if dbPointer != nil {
      sqlite3_close(dbPointer)

      return
    }
  }
}
