import Foundation

import SQLite
import Echo

extension SwiftSQLite {
  /*
  // Execute
  func execute(sql:String) -> Bool {
    // Make sure there is a db set
    guard self.dbName.characters.count > 0 else { return false }

    // Errors
    var errorPointer:UnsafeMutablePointer<Int8> = nil
    var error:String = ""

    // Connect
    var iConnection:Int32
    iConnection = sqlite3_open(self.dbName, &self.dbPointer)
    if iConnection != 0 {
      print("Error: \(sqlite3_errmsg(dbPointer))")
    }

    // Callback


    // Execute
    var executeStatus:Int32
    dispatch_async(self.queuePointer) {

    }

    executeStatus = sqlite3_exec(dbPointer, sql, setResult(UnsafeMutablePointer<Void>, argc:UnsafeMutablePointer<Int32>, argv:UnsafeMutablePointer<UnsafeMutablePointer<Int8>>, column:UnsafeMutablePointer<UnsafeMutablePointer<Int8>>), nil, &errorPointer)
    //executeStatus = sqlite3_exec(dbPointer, sql, nil, nil, &errorPointer)
    if executeStatus != 0 {
      print("Error: \(errorPointer)")
      sqlite3_free(errorPointer)
      closeDatabase()

      return false
    }

    closeDatabase()

    return true
  }
  */

  // Set Result
  func setResult(object:UnsafeMutablePointer<Void>, argc:UnsafeMutablePointer<Int32>, argv:UnsafeMutablePointer<UnsafeMutablePointer<Int8>>, column:UnsafeMutablePointer<UnsafeMutablePointer<Int8>>) -> Int32 {
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

  private func closeDatabase() {
    if dbPointer != nil {
      sqlite3_close(dbPointer)

      return
    }
  }
}
