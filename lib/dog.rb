class Dog
    attr_accessor :name, :breed, :id

def initialize (name:, breed:, id: nil)
    @id = id
    @name = name
    @breed = breed
end

# create a dogs table.
def self.create_table
    sql = 
    <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
end

# drop the dogs table from the database.
def self.drop_table
   DB[:conn].execute("DROP TABLE IF EXISTS dogs")
end

#  inserts a new record into the database and return the instance.
def save
    sql =
    <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)

    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

    self
end

# Create a new row in the database &
# Return a new instance of the Dog class
def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
end

# the database is going to return an array representing a dog's data
def self.new_from_db (row)
    self.new(id:row[0], name: row[1], breed: row[2])
end

# return an array of Dog instances for every record in the dogs table.
def self.all
    sql = 
    <<-SQL
    SELECT * FROM dogs
    SQL

    DB[:conn].execute(sql).map do |row|
        self.new_from_db(row)
    end
end
# insert a dog into the database and then attempt to find it by calling the find_by_name method.
def self.find_by_name(name)
    sql = 
    <<-SQL
    SELECT * 
    FROM dogs 
    WHERE name = ? 
    LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
        self.new_from_db(row)
    end.first
end
# This class method takes in an ID, and should return a single Dog instance 
# for the corresponding record in the dogs table with that same ID. 
def self.find(id)
        sql = <<-SQL
          SELECT *
          FROM dogs
          WHERE id = ?
          LIMIT 1
        SQL
    
        DB[:conn].execute(sql, id).map do |row|
          self.new_from_db(row)
        end.first
      end


end