class Department
  def self.create_table
    sql = <<-SQL
            CREATE TABLE IF NOT EXISTS departments (
              id INTEGER PRIMARY KEY,
              name TEXT
            );
          SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
            DROP TABLE IF EXISTS departments;
          SQL

    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    new.tap do |department|
      department.id   = row[0]
      department.name = row[1]
      begin
        department.courses = Courses.find_all_by_department_id(department.id)
      rescue
        department.courses = []
      end
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
            SELECT *
            FROM departments
            WHERE name = :name;
          SQL

    row = DB[:conn].execute(sql, name: name).flatten

    new_from_db(row) unless row.empty?
  end

  def self.find_by_id(id)
    sql = <<-SQL
            SELECT *
            FROM departments
            WHERE id = :id;
          SQL

    row = DB[:conn].execute(sql, id: id).flatten

    new_from_db(row) unless row.empty?
  end

  attr_accessor :id, :name, :courses

  def initialize
    @courses = []
  end

  def insert
    sql = <<-SQL
            INSERT INTO departments(name)
            VALUES (:name)
          SQL

    DB[:conn].execute(sql, name: name)

    self.id = id_from_db
  end

  def update
    sql = <<-SQL
            UPDATE departments
            SET
              name = :name
            WHERE
              id = :id;
          SQL

    DB[:conn].execute(sql, name: name, id: id)
  end

  def save
    if department_exists?
      update
    else
      insert
    end
  end

  def add_course(course)
    course.department_id = id
    course.save

    courses << course
    save
  end

  private

  def id_from_db
    sql = <<-SQL
            SELECT LAST_INSERT_ROWID()
            FROM departments;
          SQL

    DB[:conn].execute(sql).flatten.first
  end

  def department_exists?
    !!id
  end
end
