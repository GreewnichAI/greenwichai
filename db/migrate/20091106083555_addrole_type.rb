class AddroleType < ActiveRecord::Migration
  def self.up
    add_column :users, "role_type", :string
  end

  def self.down
  end
end
