class AddAttsToInformation < ActiveRecord::Migration
  def self.up
    add_column :information, :att1_file_name,    :string
    add_column :information, :att1_content_type, :string
    add_column :information, :att1_file_size,    :integer
    add_column :information, :att1_updated_at,   :datetime

    add_column :information, :att2_file_name,    :string
    add_column :information, :att2_content_type, :string
    add_column :information, :att2_file_size,    :integer
    add_column :information, :att2_updated_at,   :datetime

    add_column :information, :att3_file_name,    :string
    add_column :information, :att3_content_type, :string
    add_column :information, :att3_file_size,    :integer
    add_column :information, :att3_updated_at,   :datetime

    add_column :information, :att4_file_name,    :string
    add_column :information, :att4_content_type, :string
    add_column :information, :att4_file_size,    :integer
    add_column :information, :att4_updated_at,   :datetime
  end

  def self.down
  end
end
