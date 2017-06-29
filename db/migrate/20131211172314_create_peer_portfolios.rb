class CreatePeerPortfolios < ActiveRecord::Migration
  def self.up
    create_table :peer_portfolios do |t|
      t.integer :user_id
      t.integer :fund_id

      t.timestamps
    end
  end

  def self.down
    drop_table :peer_portfolios
  end
end
