class AddUserCompanyName < ActiveRecord::Migration
  def self.up
    add_column "users", "company_name", :string
  end

  def self.down
  end
end
