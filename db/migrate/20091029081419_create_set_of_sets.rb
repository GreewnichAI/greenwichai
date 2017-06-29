class CreateSetOfSets < ActiveRecord::Migration
  def self.up
    create_table :set_of_sets do |t|
      t.string "name"
      t.timestamps
    end
  end

  def self.down
    drop_table :set_of_sets
  end
end
