class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
			t.integer :user_id
			t.string :msg
			t.string :from
			t.read_at :datetime
			t.archived_at :datetime
      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
