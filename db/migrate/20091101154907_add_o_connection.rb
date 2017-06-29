class AddOConnection < ActiveRecord::Migration
  def self.up
    add_column "users", "connection_id", :integer
    add_column "users", "owner_id", :integer
    
  end

  def self.down
  end
end
