class Course
  attr_accessor :id, :name, :department_id

  def self.create_table
    sql = <<-SQL
            CREATE TABLE IF NOT EXISTS courses (
              id INTEGER PRIMARY KEY,
              name TEXT,
              department_id INTEGER
            );
          SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
            DROP TABLE IF EXISTS courses;
          SQL

    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    new.tap do |course|
      course.id            = row[0]
      course.name          = row[1]
      course.department_id = row[2]
      begin
        course.department = Department.find_by_id(course.department_id)
      rescue
        next
      end
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
            SELECT *
            FROM courses
            WHERE name = :name;
          SQL

    row = DB[:conn].execute(sql, name: name).flatten

    new_from_db(row) unless row.empty?
  end

  def self.find_all_by_department_id(department_id)
    sql = <<-SQL
            SELECT *
            FROM courses
            WHERE department_id = :department_id;
          SQL

    rows = DB[:conn].execute(sql, department_id: department_id)

    rows.map { |row| new_from_db(row) }
  end

  def self.find_by_id(id)
    sql = <<-SQL
            SELECT *
            FROM courses
            WHERE id = :id;
          SQL

    row = DB[:conn].execute(sql, id: id).flatten

    new_from_db(row) unless row.empty?
  end

  attr_accessor :id, :name, :department_id
  attr_reader :department

  def insert
    sql = <<-SQL
            INSERT INTO courses(name, department_id)
            VALUES (:name, :department_id);
          SQL

    DB[:conn].execute(sql, name: name, department_id: department_id)

    self.id = id_from_db
  end

  def update
    sql = <<-SQL
            UPDATE courses
            SET
              name = :name,
              department_id = :department_id
            WHERE
              id = :id;
          SQL

    DB[:conn].execute(sql, name: name, department_id: department_id, id: id)
  end

  def save
    if course_exists?
      update
    else
      insert
    end
  end

  def department=(department)
    @department = department
    @department_id = department.id
    department.courses << self
  end

  private

  def id_from_db
    sql = <<-SQL
            SELECT LAST_INSERT_ROWID()
            FROM courses;
          SQL

    DB[:conn].execute(sql).flatten.first
  end

  def course_exists?
    !!(Course.find_by_id(id))
  end
end
