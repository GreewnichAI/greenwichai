class AddIsArchivedToInformation < ActiveRecord::Migration
  def self.up
    add_column :information, :is_fresh, :boolean
    add_index(:information, :is_fresh)
  end

  def self.down
    remove_column :information, :is_fresh
    remove_index(:information, :is_fresh)
  end
end
