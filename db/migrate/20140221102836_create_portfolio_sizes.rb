class CreatePortfolioSizes < ActiveRecord::Migration
  def self.up
    create_table :portfolio_sizes do |t|
      t.integer :fund_0
      t.integer :fund_1
      t.integer :fund_2
      t.integer :fund_3
      t.integer :fund_4
      t.integer :fund_5
      t.integer :fund_6
      t.integer :fund_7
      t.integer :fund_8
      t.integer :fund_9

      t.timestamps
    end
  end

  def self.down
    drop_table :portfolio_sizes
  end
end
