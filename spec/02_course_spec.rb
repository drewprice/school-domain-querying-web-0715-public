require_relative 'spec_helper'

describe Course do

  before do
    Course.create_table
  end

  after do
    Course.drop_table
  end


  describe 'attributes' do
    it 'has an id, name, and department_id' do
      attributes = {
        :id => 1,
        :name => "Advanced .NET Programming",
        :department_id => 1
      }

      dot_net = Course.new
      dot_net.id = attributes[:id]
      dot_net.name = attributes[:name]
      dot_net.department_id = attributes[:department_id]

      expect(dot_net.id).to eq(attributes[:id])
      expect(dot_net.name).to eq(attributes[:name])
      expect(dot_net.department_id).to eq(attributes[:department_id])
    end
  end

  describe '.create_table' do
    it 'creates a Courses table' do
      Course.drop_table
      Course.create_table

      table_check_sql = "SELECT tbl_name FROM sqlite_master WHERE type='table' AND tbl_name='courses';"
      expect(DB[:conn].execute(table_check_sql)[0]).to eq(['courses'])
    end
  end

  describe '.drop_table' do
    it "drops the Courses table" do
      Course.create_table
      Course.drop_table

      table_check_sql = "SELECT tbl_name FROM sqlite_master WHERE type='table' AND tbl_name='courses';"
      expect(DB[:conn].execute(table_check_sql)[0]).to be_nil
    end
  end

  describe '#insert' do
    it 'inserts the Course into the database' do
      dot_net = Course.new
      dot_net.name = "Advanced .NET Programming"

      dot_net.insert

      select_sql = "SELECT name FROM Courses WHERE name = 'Advanced .NET Programming'"
      result = DB[:conn].execute(select_sql)[0]

      expect(result[0]).to eq("Advanced .NET Programming")
    end

    it 'updates the current instance with the ID of the Course from the database' do
      dot_net = Course.new
      dot_net.name = "Advanced .NET Programming"

      dot_net.insert

      expect(dot_net.id).to eq(1)
    end
  end

  describe '.new_from_db' do
    it 'creates an instance with corresponding attribute values' do
      row = [1, "Advanced .NET Programming"]
      dot_net = Course.new_from_db(row)

      expect(dot_net.id).to eq(row[0])
      expect(dot_net.name).to eq(row[1])
    end
  end

  describe '.find_by_name' do
    it 'returns an instance of Course that matches the name from the DB' do
      dot_net = Course.new
      dot_net.name = "Advanced .NET Programming"

      dot_net.insert

      dot_net_from_db = Course.find_by_name("Advanced .NET Programming")
      expect(dot_net_from_db.name).to eq("Advanced .NET Programming")
      expect(dot_net_from_db).to be_an_instance_of(Course)
    end
  end

  describe '.find_all_by_department_id' do
    it "returns records matching a property" do
      dot_net = Course.new
      dot_net.name = "Advanced .NET Programming"
      dot_net.department_id = 9999

      dot_net.insert

      dot_net_from_db = Course.find_all_by_department_id(9999)[0]

      expect(dot_net_from_db.name).to eq("Advanced .NET Programming")
      expect(dot_net_from_db).to be_an_instance_of(Course)
    end
  end

  describe "#update" do
    it 'updates and persists a Course in the database' do
      dot_net = Course.new
      dot_net.name = "Advanced .NET Programming"
      dot_net.insert

      dot_net.name = "Underwater Basket Weaving"
      dot_net.department_id = 2
      original_id = dot_net.id

      dot_net.update

      dot_net_from_db = Course.find_by_name("Advanced .NET Programming")
      expect(dot_net_from_db).to be_nil

      underwater_from_db = Course.find_by_name("Underwater Basket Weaving")
      expect(underwater_from_db).to be_an_instance_of(Course)
      expect(underwater_from_db.name).to eq("Underwater Basket Weaving")
      expect(underwater_from_db.department_id).to eq(2)
      expect(underwater_from_db.id).to eq(original_id)
    end
  end

  describe '#save' do
    it "chooses the right thing on first save" do
      dot_net = Course.new
      dot_net.name = "Advanced .NET Programming"
      expect(dot_net).to receive(:insert)
      dot_net.save
    end

    it 'chooses the right thing for all others' do
      dot_net = Course.new
      dot_net.name = "Advanced .NET Programming"
      dot_net.save

      dot_net.name = "Underwater Basket Weaving"
      expect(dot_net).to receive(:update)
      dot_net.save
    end
  end
end
