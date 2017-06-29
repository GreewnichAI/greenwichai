class AddF30byF51by < ActiveRecord::Migration
  def self.up
    add_column "userinformation1", "f30_by", :string
    add_column "information", "f51_by", :string
  end

  def self.down
  end
end
