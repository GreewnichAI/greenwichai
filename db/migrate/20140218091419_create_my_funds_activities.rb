class CreateMyFundsActivities < ActiveRecord::Migration
  def self.up
    create_table :my_funds_activities do |t|
      t.integer :counts
      t.integer :month
      t.month :year

      t.timestamps
    end
  end

  def self.down
    drop_table :my_funds_activities
  end
end
