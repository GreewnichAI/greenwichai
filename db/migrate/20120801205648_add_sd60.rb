class AddSd60 < ActiveRecord::Migration
  def self.up
    add_column "information", "sd_60", :float
    add_column "information", "sd_3", :float
  end

  def self.down
  end
end
