class AddUserphoneNumber < ActiveRecord::Migration
  def self.up
    add_column "users", "phone_number",:string
  end

  def self.down
  end
end
