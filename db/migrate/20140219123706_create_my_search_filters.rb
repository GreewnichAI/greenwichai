class CreateMySearchFilters < ActiveRecord::Migration
  def self.up
    create_table :my_search_filters do |t|
      t.integer :lrm
      t.integer :ytd
      t.integer :car
      t.integer :cr
      t.integer :md
      t.integer :sd
      t.integer :shape

      t.timestamps
    end
  end

  def self.down
    drop_table :my_search_filters
  end
end
