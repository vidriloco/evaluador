class CreateExamenes < ActiveRecord::Migration
  def self.up
    create_table :examenes do |t|
    	t.column :metaexamen_id, :integer
    	t.column :nombre, 	     :string
    	t.column :supervisor, 	 :string
    	t.column :respuestas, 	 :text
    	t.column :fecha, 				 :date
    end
  end

  def self.down
    drop_table :examenes
  end
end
