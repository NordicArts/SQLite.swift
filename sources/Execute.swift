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

  // Result
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
}
