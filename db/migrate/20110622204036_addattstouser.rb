class Addattstouser < ActiveRecord::Migration
  def self.up
    add_column :users, :att1_file_name,    :string
    add_column :users, :att1_content_type, :string
    add_column :users, :att1_file_size,    :integer
    add_column :users, :att1_updated_at,   :datetime

    add_column :users, :att2_file_name,    :string
    add_column :users, :att2_content_type, :string
    add_column :users, :att2_file_size,    :integer
    add_column :users, :att2_updated_at,   :datetime

    add_column :users, :att3_file_name,    :string
    add_column :users, :att3_content_type, :string
    add_column :users, :att3_file_size,    :integer
    add_column :users, :att3_updated_at,   :datetime

    add_column :users, :att4_file_name,    :string
    add_column :users, :att4_content_type, :string
    add_column :users, :att4_file_size,    :integer
    add_column :users, :att4_updated_at,   :datetime

  end

  def self.down
  end
end
