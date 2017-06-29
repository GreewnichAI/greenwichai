class AddActive < ActiveRecord::Migration
  def self.up
  	add_column "users", "active", :integer
  end

  def self.down
  end
end
