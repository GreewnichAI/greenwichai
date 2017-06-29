class Manager < ActiveRecord::Base
	set_table_name "manager_information"
	def users
		rez = ActiveRecord::Base.connection.execute("SELECT donor_id,manager_id FROM manager_to_profiles mtp JOIN users u ON mtp.donor_id=u.owner_id WHERE mtp.manager_id = "+self.manager_id.to_s)
		donors = []
		while row = rez.fetch_hash do
			donors << row['donor_id']
		end
		User.find(:all, :conditions=>["owner_id in (?)", donors])
	end
	
	
	def fund_names
		cond_def = " and F20 not like  '% DELETE %'  and F20 not like '% WRI %'  and F20 not like '%DEFUNCT%'"
		fund_names = ""
		rez=ActiveRecord::Base.connection.execute( "SELECT i.f20 FROM manager_to_fund mtf JOIN information i ON mtf.fund_id=i.id_1 WHERE mtf.manager_id="+self.manager_id.to_s+cond_def)
		while row = rez.fetch_row do
				fund_names = fund_names + row[0] + "<br/>"
		end
		
		return fund_names
	end
	
	def first_fund_id
		mtf = ManagerToFund.find(:first, :conditions=>["manager_id=?",self.manager_id])
		ret_id = 0
		if !mtf.nil?
			ret_id = Information.find(:first, :conditions=>["id_1 = ?", mtf.fund_id]).id
		end
		ret_id
	end
end
