// Core
import Foundation

// Third Party
import SQLite
import Echo

#if os(Linux)
  import Glibc
#endif

// MARK: SQLite
public class SwiftSQLite {
  var tableName:String  = ""
  var dbName:String     = "SwiftSQLite.db"

  public var dbPointer:COpaquePointer       = nil
  public var dateFormat                     = NSDateFormatter()
  public var GROUP                          = ""
  public var queue                          = "SQliteSwift"
  public var queuePointer:dispatch_queue_t

  var columns:[String]        = []
  var results:[String:String] = [:]

  var nullValues:[String]     = []
  var values:[String:String]  = [:]
  var nullWheres:[String]     = []
  var wheres:[String:String]  = [:]
  var resultColumns:[String]  = []

  // Init
  init() {
    self.queuePointer = dispatch_queue_create(self.queue, DISPATCH_QUEUE_CONCURRENT)

    dateFormat.timeZone = NSTimeZone(forSecondsFromGMT: 0)
  }

  public func setDb(database:String) -> Void {
    self.dbName = database + ".db"
  }

  public func setTable(table:String) -> Void {
    self.tableName = table
  }

  func stripComma(sql:String) -> String {
    return stripExtra(sql, length: 1)
  }

  func stripExtra(sql:String, length:Int) -> String {
    var newSql    = sql
    let newLength = (0 - length)

    let range = newSql.endIndex.advancedBy(newLength)..<newSql.endIndex
    newSql.removeRange(range)

    return newSql
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
