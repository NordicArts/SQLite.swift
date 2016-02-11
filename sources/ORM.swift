extension SQLiteSwift {
    func setColumn(column:String) -> Void {
        return setValue(column)
    }
    
    // Update NULL Values
    func setValue(column:String) -> Void {
        self.nullValues[column] = ""
    
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
        self.nullWheres[column] = ""
        
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
        guard self.values != 0 else { return }

        sql:String = "UPDATE \(self.tableName) SET "
        
        // Values with value
        for (column, value) in self.values {
            sql += "\(column) = \(value),"
        }

        // Null Vaues
        for value in self.nullValues {
            sql += "\(value) = NULL,"
        }

        // Remove the extra ,
        let range = sql.endIndex.advancedBy(-1)..<sql.endIndex
        sql.removeRange(range)

        // Add a space
        sql += " "

        // Where
        if self.wheres.count >= 1 {
            var i = 0
            for (column, value) in self.wheres {
                // skip the first one
                if i == 0 { 
                    sql += " WHERE \(column) = \(value) "

                    i += 1
                } else {
                    sql += " AND \(column) = \(value) "
                }
            }
        }

        //NULL Where
        if self.nullWheres.count >= 1 {
            var i = 0
            for column in self.nullWheres {
                if i == 0 {
                    if self.wheres.count >= 1 {
                        sql += " AND \(column)  = NULL " 
                    } else {
                        sql += " WHERE \(column) = NULL " 
                    }

                    i += 1
                } else {
                    sql += " AND \(column) = NULL "
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
        for (column, value) in self.values {
            sql += "\(column),"
        }

        // NULL Value Columns
        for column in self.nullValues {
            sql += "\(column),"
        }

        // Strip the extra ,
        let range = ""

        // End the columns
        sql += ") VALUES "
        

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
        return del("")
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
