namespace :misc do
	
	task :sync_funds_managers => :environment do
    Information.all.each do |i|
      mtf = ManagerToFund.first(:conditions=>["fund_id = ?", i.id_1])
      if !mtf.nil?
        i.manager_id = mtf.manager_id
        i.save
      end
    end
  end
end
