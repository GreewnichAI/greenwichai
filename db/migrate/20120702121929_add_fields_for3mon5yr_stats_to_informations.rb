class AddFieldsFor3mon5yrStatsToInformations < ActiveRecord::Migration
  def self.up
    add_column :information, :car_60, :float
    add_column :information, :sharpe_60, :float
    add_column :information, :md_60, :float
    add_column :information, :cr_60, :float
    
    add_column :information, :car_3, :float
    add_column :information, :sharpe_3, :float
    add_column :information, :md_3, :float
    add_column :information, :cr_3, :float
  end

  def self.down
    remove_column :information, :car_60
    remove_column :information, :sharpe_60
    remove_column :information, :md_60
    remove_column :information, :cr_60
    
    remove_column :information, :car_3
    remove_column :information, :sharpe_3
    remove_column :information, :md_3
    remove_column :information, :cr_3
  end
end
