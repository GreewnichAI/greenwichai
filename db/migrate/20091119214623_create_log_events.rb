class CreateLogEvents < ActiveRecord::Migration
  def self.up
    create_table :log_events do |t|
			t.string :c
			t.string :m
			t.string :p
			t.string :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :log_events
  end
end
