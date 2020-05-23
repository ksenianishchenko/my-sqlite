require "csv"
require "./helpers.rb"

class MySqliteRequest

    def initialize()
        @request = []
        @selectedColumns = []
        @sortedTable = []
        @tableName = nil

        return self
    
    end

    def from(table_name)

        @tableName = table_name
        
        @table = readFromCSVFile(table_name)

        return self
    end

    def select(column_name)

        if column_name == "*"
            @selectedColumns = @table
        else
            @table.map do |hash|
                newHash = nil
                if column_name.kind_of?(Array)
                    newHash = hash.select { |key,_| column_name.include? key }
                else 
                    newHash = hash.select { |key,_| key == column_name }
                end
                @selectedColumns.push(newHash)
            end
        end

        @request = []
        @request = @selectedColumns

        return self

    end

    def where(column_name, criteria)

        if !column_name || !criteria
            return self
        end

        @filterByCriteria = []

        if @selectedColumns.length == 0
            @selectedColumns = @table
        end

        @selectedColumns.map do |hash|
            
            if hash[column_name] == criteria
                @filterByCriteria.push(hash)
            end
        end

        @request = []
        @request = @filterByCriteria

        return self

    end

    def insert(table_name)

        self.from(table_name)
        @values = Hash.new(0)

        if @table[0]
            keys = @table[0].keys

            keys.each_with_index { |val, index|
                @values[val] = @data[index]
            }
        end

        @table.push(@values)
        
        updateTable(table_name, @table)
    
        return self
    end

    def values(data)

        @data = data

        return self

    end

    def set(data)

        @data = data

        return self
    end

    def update(table_name)
        self.from(table_name)
        index = []
        @table.each_with_index { |val, i|
            @filterByCriteria.each { |v|
                if val == v
                    index = i
                end
            }
        }

        @data.each { |key, val|
            @table[index][key] = val
        }
        updateTable(table_name, @table)
        return self
    end

    def delete()

        @table.each { |val|
            @filterByCriteria.each { |v|

                if val == v
                    @table.delete(val)
                end

            }
        }

        updateTable(@tableName, @table)

        return self
    end

    def order(order, column_name)

        @sortedTable = @selectedColumns.sort_by { |k| k[column_name] }

        if order == "DESC"
            @sortedTable.reverse!
        end

        @request = []
        @request = @sortedTable

        return self
    end

    def join(column_on_db_a, filename_db_b, column_on_db_b)

        @joinedTable = []
        @secondTable = readFromCSVFile(filename_db_b)
        
        @joinedTable = joinTables(@table, @secondTable, column_on_db_a, column_on_db_b)

        @request = []
        @request = @joinedTable

        return self
    end

    def run()
        return @request
    end

end

#request = MySqliteRequest.new()
#request = request.from("students")
#request = request.select(["name", "email"])
#request = request.where("name", "Mila")
#request = request.values(["John", "john@johndoe.com", "A", "https://blog.johndoe.com"])
#request = request.insert("students")
#request = request.set({"email" => "liam@johndoe.com", "blog" => "https://blog.liam.com"})
#request = request.update("students")
#request = request.delete()
#request = request.order("DESC", "name")
#request = request.join("name", "ditails", "student")
#request.run()