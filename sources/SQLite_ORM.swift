extension SwiftSQLite {
    // Result Columns
    func addResultColumns(columns: [String]) -> Void {
      for column in columns {
        addResultColumns(column)
      }
    }
    func addResultColumns(column:String) -> Void {
      self.resultColumns.append(column)
    }

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
        var sql:String = "DELETE FROM \(self.tableName) WHERE "

        // Wheres
        for (column, value) in self.wheres {
          sql += "\(column) = '\(value)' AND "
        }

        // NULL Wheres
        for column in self.nullWheres {
          sql += "\(column) = NULL AND "
        }

        // Strip the extra AND
        sql = stripExtra(sql, length: 4)

        // close the query
        sql += ";"

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
        var sql:String = "SELECT "

        // columns
        for column in self.resultColumns {
          sql += "\(column),"
        }

        // remove extra ,
        sql = stripComma(sql)

        // table
        sql += " FROM \(self.tableName)"

        // if there are any where clauses
        if self.wheres.count >= 1 {
          sql += " WHERE"
          for (column, value) in self.wheres {
            sql += " \(column) = '\(value)' AND"
          }
          sql = stripExtra(sql, length: 3)
        }

        // null where
        if self.nullWheres.count >= 1 {
          if self.wheres.count >= 1 {
            sql += " AND"
          } else {
            sql += " WHERE"
          }

          for column in self.nullWheres {
            sql += "\(column) = NULL AND"
          }
          sql = stripExtra(sql, length: 3)
        }

        // close the query
        sql += ";"

        // do the query
        return select(sql)
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
