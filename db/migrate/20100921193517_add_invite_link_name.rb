class AddInviteLinkName < ActiveRecord::Migration
  def self.up
    add_column "invites", "link_name", :string, :length=>1024
  end

  def self.down
  end
end
