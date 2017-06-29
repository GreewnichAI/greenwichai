class CreateMySearchActivities < ActiveRecord::Migration
  def self.up
    create_table :my_search_activities do |t|
      t.string :strategy_name
      t.integer :number_filters_used

      t.timestamps
    end
  end

  def self.down
    drop_table :my_search_activities
  end
end
