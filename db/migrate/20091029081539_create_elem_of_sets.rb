class CreateElemOfSets < ActiveRecord::Migration
  def self.up
    create_table :elem_of_sets do |t|
      t.integer :set_of_set_id
      t.string :name
      t.datetime :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :elem_of_sets
  end
end
