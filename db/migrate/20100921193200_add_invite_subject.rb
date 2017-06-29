class AddInviteSubject < ActiveRecord::Migration
  def self.up
    add_column "invites", "subject", :string, :length=>1024
  end

  def self.down
  end
end
