class CreateMyReportsCreateds < ActiveRecord::Migration
  def self.up
    create_table :my_reports_createds do |t|
      t.integer :counts
      t.integer :month
      t.integer :year

      t.timestamps
    end
  end

  def self.down
    drop_table :my_reports_createds
  end
end
