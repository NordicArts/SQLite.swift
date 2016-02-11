import Foundation
import SQLite

class SwiftSQLite {
  var dbName:String = ""
  var tableName:String = ""
  var columns:[String] = []
  var results:[String:String] = [:]

  func setDb(database:String) -> Void {
    self.dbName = database + ".db"
  }

  func setTable(table:String) -> Void {
    self.tableName = table
  }
}
