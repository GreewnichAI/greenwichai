require 'pp'
namespace :msq do
	
	task :sync_users => :environment do
			gcs = GConnection.find(:all, :conditions=>["ROLE_NAME!='TEST' AND ROLE_NAME!='EFG USER' AND WEB_ID IS NOT NULL"])
			puts gcs.size
			gcs.each do |gc|
					u=User.find(:first, :conditions=>["OWNER_ID = ?", gc.OWNER_ID])
					if u.nil?
						
						u=User.new
						u.password = u.password_confirmation = gc.WEB_PWD
						u.login=gc.WEB_ID
						u.owner_id = gc.OWNER_ID
						u.role_type = gc.ROLE_NAME
						u.old_pwd = gc.WEB_PWD
						u.save
						puts gc.WEB_ID+" "+gc.WEB_PWD+" "+u.id.to_s
					end
			end
	end
	
	task :remove_inception_dates => :environment do 
		
		rez = ActiveRecord::Base.connection.execute("SELECT id,id_1,f20 FROM information WHERE F20 LIKE '%1/%' OR F20 LIKE '%2/%' OR F20 LIKE '%3/%' OR F20 LIKE '%4/%' OR F20 LIKE '%5/%' OR F20 LIKE '%6/%' OR F20 LIKE '%7/%' OR F20 LIKE '%8/%' OR F20 LIKE '%9/%' OR f20 LIKE '%0/%'")
		while row = rez.fetch_hash do
			f20 = row['f20'].gsub(/\(\d+\/\d+\)/,"")
			inf = Information.find(row['id'])
			inf.f20 = f20
			inf.save
			puts inf.id.to_s+" "+f20
		end
		
		rez = ActiveRecord::Base.connection.execute("SELECT id,id_1,f20 FROM information WHERE F20 LIKE '%1/%' OR F20 LIKE '%2/%' OR F20 LIKE '%3/%' OR F20 LIKE '%4/%' OR F20 LIKE '%5/%' OR F20 LIKE '%6/%' OR F20 LIKE '%7/%' OR F20 LIKE '%8/%' OR F20 LIKE '%9/%' OR f20 LIKE '%0/%'")
		while row = rez.fetch_hash do
			f20 = row['f20'].gsub(/\(\d+\/\d+\/\d+\)/,"")
			inf = Information.find(row['id'])
			inf.f20 = f20
			inf.save
			puts inf.id.to_s+" "+f20
		end
		
		rez = ActiveRecord::Base.connection.execute("SELECT id,id_1,f20 FROM information WHERE F20 LIKE '%1/%' OR F20 LIKE '%2/%' OR F20 LIKE '%3/%' OR F20 LIKE '%4/%' OR F20 LIKE '%5/%' OR F20 LIKE '%6/%' OR F20 LIKE '%7/%' OR F20 LIKE '%8/%' OR F20 LIKE '%9/%' OR f20 LIKE '%0/%'")
		while row = rez.fetch_hash do
			f20 = row['f20'].gsub(/\((.*)\d+\/\d+\/\d+\)/,"")
			inf = Information.find(row['id'])
			inf.f20 = f20
			inf.save
			puts inf.id.to_s+" "+f20
		end
	end
  
end