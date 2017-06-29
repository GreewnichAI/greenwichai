class Addsubset < ActiveRecord::Migration
  def self.up
    add_column "set_of_sets", "has_subsets", :integer
    add_column "set_of_sets", "set_of_set_id", :integer
  end

  def self.down
  end
end
