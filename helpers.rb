def updateTable(table_name, table)
    filename_db = table_name + ".csv"
    headers = []

    table[0].each { |key, val|
        headers.push(key)
    }

    CSV.open(filename_db, "wb") do |csv|
        csv << headers
        table.each do |hash|
            csv << hash.values
        end
    end
end

def readFromCSVFile(table_name)
    table = nil
    filename_db = table_name + ".csv"

    if filename_db

        table = CSV.foreach(filename_db, headers: true).map{ |row| row.to_h }

    else 
        print "No such file"
        return nil
    end

    return table
end

def joinTables(table_a, table_b, column_on_db_a, column_on_db_b)
    tempTableA = []
    tempTableB = []
    joinedTable = []

    table_a.each { |hash|
        table_b.each { |h|

            if hash[column_on_db_a] == h[column_on_db_b]
                tempTableA.push(hash)
                tempTableB.push(h)
            end

        } 
    }

    tempTableA.each { |hash|

        newHash = Hash.new(0)

        tempTableB.each { |h|

            newHash = hash.merge!(h.select{ |k,_| not hash.has_key? k })

        }

        joinedTable.push(newHash)

    }

    return joinedTable
end