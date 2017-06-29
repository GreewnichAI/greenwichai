class AddDescription < ActiveRecord::Migration
  def self.up
  	add_column "set_of_sets", "description", :string  
  end

  def self.down
  end
end
