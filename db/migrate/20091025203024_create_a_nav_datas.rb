class CreateANavDatas < ActiveRecord::Migration
  def self.up
    create_table :a_m_datas do |t|
			t.integer :fund_id
			t.date :date_of
			t.string :return
			t.string :fundsmanaged
			t.string :nav
			t.string :estimate
      t.timestamps
    end
    create_table :a_w_datas do |t|
			t.integer :fund_id
			t.date :date_of
			t.string :return
			t.string :fundsmanaged
			t.string :nav
			t.string :estimate
      t.timestamps
    end
    create_table :a_d_datas do |t|
			t.integer :fund_id
			t.date :date_of
			t.string :return
			t.string :fundsmanaged
			t.string :nav
			t.string :estimate
      t.timestamps
    end
  end

  def self.down
    drop_table :a_nav_datas
  end
end
