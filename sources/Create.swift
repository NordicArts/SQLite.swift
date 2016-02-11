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
