class AddFund9ToPortfolioSize < ActiveRecord::Migration
  def self.up
    add_column :portfolio_sizes, :fund_10, :integer
  end

  def self.down
    remove_column :portfolio_sizes, :fund_10
  end
end
