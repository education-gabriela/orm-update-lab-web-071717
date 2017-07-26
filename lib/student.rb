require_relative "../config/environment.rb"

class Student
  attr_accessor :id, :name, :grade
  FIELDS = [:id, :name, :grade]

  def initialize( id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO students(name, grade) VALUES (?, ?)"
      DB[:conn].prepare(sql).execute(self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students").first.first
    end
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].prepare(sql).execute(self.name, self.grade, self.id)
  end

  def self.create(name, grade)
    student = self.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    self.new(*row)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students WHERE name = ? LIMIT 1
    SQL

    result = DB[:conn].execute(sql, name)
    self.new_from_db(result.first)
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE students")
  end
end
