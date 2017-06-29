class AddInviteText < ActiveRecord::Migration
  def self.up
    add_column :invites, :txt, :text
  end

  def self.down
  end
end
