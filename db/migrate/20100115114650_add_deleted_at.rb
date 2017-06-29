class AddDeletedAt < ActiveRecord::Migration
  def self.up
  	add_column "messages", "archived_at", :date
  	add_column "messages", "deleted_at", :date
  end

  def self.down
  end
end
