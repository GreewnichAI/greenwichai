class AddFundAddedBy < ActiveRecord::Migration
  def self.up
    add_column "information", "added_by", :string
  end

  def self.down
  end
end
