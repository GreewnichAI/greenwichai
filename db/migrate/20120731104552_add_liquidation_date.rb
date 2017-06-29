class AddLiquidationDate < ActiveRecord::Migration
  def self.up
      add_column "information","liquidation_date", :date
  end

  def self.down
  end
end
