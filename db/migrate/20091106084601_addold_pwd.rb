class AddoldPwd < ActiveRecord::Migration
  def self.up
    add_column "users", "old_pwd", :string
  end

  def self.down
  end
end
