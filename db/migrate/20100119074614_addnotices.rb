class Addnotices < ActiveRecord::Migration
  def self.up
  	add_column "information", "wri_notes", :string
  	add_column "information", "defunct_notes", :string
  end

  def self.down
  end
end
