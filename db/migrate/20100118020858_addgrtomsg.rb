class Addgrtomsg < ActiveRecord::Migration
  def self.up
  	add_column "messages", "gr", :string
  end

  def self.down
  end
end
