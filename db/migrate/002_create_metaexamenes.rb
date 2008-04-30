class CreateMetaexamenes < ActiveRecord::Migration
  def self.up
    create_table :metaexamenes do |t|
    	t.column :descriptor,   :string
    	t.column :campana,			:string
 			t.column :rubro,				:string
 			t.column :area,					:string
 			t.column :preguntas, 		:text
 			t.column :tiempo, 			:integer
    end
  end

  def self.down
    drop_table :metaexamenes
  end
end
