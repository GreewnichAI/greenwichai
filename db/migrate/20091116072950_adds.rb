class Adds < ActiveRecord::Migration
  def self.up
    add_column "set_of_sets", "elem_of_set_id", :integer
  end

  def self.down
  end
end
