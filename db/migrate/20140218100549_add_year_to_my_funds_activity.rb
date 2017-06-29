class AddYearToMyFundsActivity < ActiveRecord::Migration
  def self.up
    add_column :my_funds_activities, :year, :integer
  end

  def self.down
    remove_column :my_funds_activities, :year
  end
end
