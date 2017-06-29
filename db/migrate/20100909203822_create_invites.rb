class CreateInvites < ActiveRecord::Migration
  def self.up
    create_table :invites do |t|
      t.integer :firm_id
      t.integer :fund_id
      t.integer :user_id
      t.string :email
      t.string :act_key
      t.string :status
      t.timestamps
    end
  end

  def self.down
    drop_table :invites
  end
end
