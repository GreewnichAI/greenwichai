class CreateMyPerformaceSummaryActivities < ActiveRecord::Migration
  def self.up
    create_table :my_performace_summary_activities do |t|
      t.integer :counts
      t.integer :month
      t.integer :year

      t.timestamps
    end
  end

  def self.down
    drop_table :my_performace_summary_activities
  end
end
