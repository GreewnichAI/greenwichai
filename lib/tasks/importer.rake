require 'pp'
namespace :importer do
	task :add_ids => :environment do 
    rez=ActiveRecord::Base.connection.execute("show tables")
    while row = rez.fetch_hash do 
      table_name = row["Tables_in_greenwich"]
      rez2=ActiveRecord::Base.connection.execute("describe "+table_name)
      b = false
      while row2 = rez2.fetch_hash
        b = true if row2['Field']=="id"
      end
      if b==false
        puts "Adding ID to "+table_name
        ActiveRecord::Base.connection.execute("alter table "+table_name+" add id int(11) auto_increment primary key")
      end
    end
  end
  
	task :add_seq3 => :environment do
			table_names = []
			table_names << "PERFORMANCE"
	  	table_names << "INFORMATION"
	  	table_names << "DAILYDATA"
	  	table_names << "DAILYDATA_DAY"
	  	table_names << "MANAGER_TO_FUND"
	  	table_names << "USERINFORMATION4"
	  	table_names << "MANAGER_TO_PROFILES"
  		table_names << "SYSTEMINFORMATION1"
  		table_names = []
  		table_names << "SYSTEMINFORMATION5"
  		table_names.each do |tb|
  			
  			
  			q = "
CREATE OR REPLACE TRIGGER "+tb+"_trigger
BEFORE INSERT
ON PERFORMANCE
REFERENCING NEW AS NEW
FOR EACH ROW
BEGIN
SELECT "+tb+"_seq.nextval INTO :NEW.ID FROM dual;
END;"
ActiveRecord::Base.connection.execute(q)

  			puts tb
  		end
  		ActiveRecord::Base.connection.execute("commit")
		
	end	
	
	task :add_seq2 => :environment do
			table_names = []
			table_names << "PERFORMANCE"
	  	table_names << "INFORMATION"
	  	table_names << "DAILYDATA"
	  	table_names << "DAILYDATA_DAY"
	  	table_names << "MANAGER_TO_FUND"
	  	table_names << "USERINFORMATION4"
	  	table_names << "MANAGER_TO_PROFILES"
  		table_names << "SYSTEMINFORMATION1"
  		table_names = []
  		table_names << "SYSTEMINFORMATION5"
  		table_names.each do |tb|
  			q = "select max(id)+1 as MX from "+tb
  			rz = ActiveRecord::Base.connection.execute(q)
  			rw = rz.fetch_hash
  			mx = rw['MX']
  			q = "create sequence "+tb+"_seq start with "+mx.to_i.to_s+" increment by 1"
  			ActiveRecord::Base.connection.execute(q)
  			q = "
CREATE OR REPLACE TRIGGER PERFORMANCE_trigger
BEFORE INSERT
ON PERFORMANCE
REFERENCING NEW AS NEW
FOR EACH ROW
BEGIN
SELECT "+tb+"_seq.nextval INTO :NEW.ID FROM dual;
END;"
  			puts tb
  		end
  		ActiveRecord::Base.connection.execute("commit")
		
	end	
	
  task :add_seq => :environment do
	  	table_name = "PERFORMANCE"
	  	table_name = "INFORMATION"
	  	table_name = "DAILYDATA"
	  	table_name = "DAILYDATA_DAY"
	  	table_name = "MANAGER_TO_FUND"
	  	table_name = "USERINFORMATION4"
	  	table_name = "MANAGER_TO_PROFILES"
	  	table_name = "SYSTEMINFORMATION1"
	  	table_name = "MANAGER_INFORMATION"
  		table_name = "SYSTEMINFORMATION5"
  		
  		ActiveRecord::Base.connection.execute("alter table "+table_name+" add (ID int)")
  		#ActiveRecord::Base.connection.execute("update "+table_name+" set ID=null where ID is not null")
  		rez  = ActiveRecord::Base.connection.execute("select MAX(ID) as MX from "+table_name)
  		row = rez.fetch_hash
  		
  		i = 0
  		i = row['MX'].to_i if !row.nil?
			rez = ActiveRecord::Base.connection.execute("select * from "+table_name+" where ID is null")
			while (row = rez.fetch_hash) do 
				i = i + 1
				if table_name=="PERFORMANCE" or table_name=="DAILYDATA" or table_name=="DAILYDATA_DAY"
						q = "update "+table_name+" set ID="+i.to_s+" where ID_1 = "+row['ID_1'].to_s+" and DATE_1 = TO_DATE('"+row['DATE_1'].to_time.strftime("%Y%m%d")+"','YYYYmmdd')" 
				end
				if table_name=="INFORMATION" or table_name=="USERINFORMATION4" or table_name=="SYSTEMINFORMATION1" or table_name=="SYSTEMINFORMATION5"
						q = "update "+table_name+" set ID="+i.to_s+" where ID_1 = "+row['ID_1'].to_s 
				end
				if table_name=="MANAGER_TO_FUND"
						q = "update "+table_name+" set ID="+i.to_s+" where FUND_ID = "+row['FUND_ID'].to_s 
				end
				
				if table_name=="MANAGER_TO_PROFILES"
						q = "update "+table_name+" set ID="+i.to_s+" where MANAGER_ID = "+row['MANAGER_ID'].to_s+" and DONOR_ID = "+row['DONOR_ID'].to_s
				end
				
				if table_name=="MANAGER_INFORMATION"
						q = "update "+table_name+" set ID="+i.to_s+" where MANAGER_ID = "+row['MANAGER_ID'].to_s
				end
				
				puts i				 if (i%500==0)
				if table_name=="MANAGER_TO_FUND" and !row['FUND_ID'].to_s.blank?
						ActiveRecord::Base.connection.execute(q) 
				else
						ActiveRecord::Base.connection.execute(q) 
				end
				ActiveRecord::Base.connection.execute("commit") if (i%500==0)
				
			end
			

  end
  
  task :import_users => :environment do
  		# O_CONNECTION_ID O_OWNER_ID
  		rez = ActiveRecord::Base.connection.execute("select * from G_CONNECTIONS where ROLE_NAME='External User Manager'")
  		while (row = rez.fetch_hash)
  				u=User.new
  				u.connection_id = row['CONNECTION_ID']
  				u.owner_id = row['OWNER_ID']
  				u.login = row['WEB_ID']
  				
  				u.password = u.password_confirmation = row['WEB_PWD']
  				u.name=""
  				u.tip="member"
  				u.save
  				# pp u.errors
  		end
	end
  
  task :stratAB => :environment do
  		k = 0 
  		a = []
  		Information.all(:conditions=>["f49 is null"]).each do |i|
  			k = k + 1
  			b = 0
  			puts "INF: "+i.id.to_s+" = "+k.to_s
  			if (i.f15 == "Long-Short Equity Group" and i.f37 == "Long-Short Equity"  and i.f39 == "Growth")
  				i.f49 = "Long/Short Equity - Growth"
  			elsif (i.f15 == "Long-Short Equity Group" and i.f37 == "Long-Short Equity" and i.f39 == "Value")
  				i.f49 = "Long/Short Equity - Value"
  			elsif (i.f15 == "Long-Short Equity Group" and i.f37 == "Long-Short Equity" and i.f39 == "Opportunistic")
  				i.f49="Long/Short Equity - Opportunistic"
  			elsif i.f15 == "Long-Short Equity Group" and i.f37 == "Long-Short Equity" and i.f39 == "Short Selling"
  				i.f49="Short-Biased"
  			elsif i.f15 == "Market Neutral Group" and i.f37 == "Equity Market Neutral"
  				i.f49="Equity Market Neutral"
  			elsif i.f15 == "Market Neutral Group" and i.f37 == "Arbitrage" and i.f39 == "Convertible Arbitrage"
  				i.f49="Convertible Arbitrage"
  			elsif i.f15 == "Market Neutral Group" and i.f37 == "Event-Driven" and i.f39 == "Merger Arbitrage"
  				i.f49="Merger Arbitrage"
  			elsif i.f15 == "Market Neutral Group" and i.f37 == "Arbitrage" and i.f39 == "Fixed Income Arbitrage"
  				i.f49="Fixed Income Arbitrage"
  			elsif i.f15 == "Specialty Strategies Group" and i.f37 == "Fixed Income"
  				i.f49="Fixed Income"
  			elsif i.f15 == "Market Neutral Group" and i.f37 == "Arbitrage" and i.f39 == "Several Arb Strategies"
  				i.f49="Multiple Arbitrage Strategies"
  			elsif i.f15 == "Market Neutral Group" and i.f37 == "Event-Driven" and i.f39 == "Distressed Securities"
  				i.f49="Distressed Securities"
  			elsif i.f15 == "Market Neutral Group" and i.f37 == "Event-Driven" and i.f39 == "Several Strategies"
  				i.f49="Multiple Event-Driven Strategies"
  			elsif i.f15 == "Directional Trading Group" and i.f37 == "Macro"
  				i.f49="Macro"
  			elsif i.f15 == "Directional Trading Group" and i.f37 == "Futures" and i.f39 == "Systematic"
  				i.f49="Futures - Systematic"
  			elsif i.f15 == "Directional Trading Group" and i.f37 == "Futures" and (i.f39 == "Discretionary" or i.f39.to_s == "")
  				i.f49="Futures - Discretionary"
  			elsif i.f15 == "Specialty Strategies Group" and i.f37 == "Multi-Strategy"
  				i.f49="Multi-Strategy"
  			elsif i.f15 == "Fund of Funds Group" and i.f37 == "Fund of Funds"
  				i.f49="Fund of Funds"
  			else 
  			a << i
  			b = 1
  			end
  			i.save if b==0
  		end
  		pp = a.map {|c| c.object_id}
  		puts pp.join(", ")
  end
  
  task :stratBC => :environment do
  		Information.all(:conditions=>["f49 is not null or f38 is not null or f40 is not null or f48 is not null or f41 is not null "]).each do |i|
        puts i.id.to_s
  			uc7 = i.usercheck7
  			uc7.update_f49(i.f49) if !i.f49.to_s.strip.blank?
  			uc7.update_f38(i.f38) if !i.f38.to_s.strip.blank?
  			uc7.update_f40(i.f40) if !i.f40.to_s.strip.blank?
  			uc7.update_f48(i.f48) if !i.f48.to_s.strip.blank?
  			uc7.update_f41(i.f41) if !i.f41.to_s.strip.blank?
  		end
    end
    
    task :library => :environment do 
      
      categ = { "Monthly Index Research"=> 1, "Press Release"=>2, "Publication Reprint"=>4, "Research Paper"=>5}
      require 'parseexcel'
      workbook = Spreadsheet::ParseExcel.parse("Catalog_of_GV_Library.xls") 
      worksheet = workbook.worksheet(0)
      worksheet.each(1) { |row|
        entry = ActiveRecord::Base.connection.quote(row.at(0).to_s("latin1")).gsub("''","'")
        date = row.at(1).date
        category = row.at(2).to_s("latin1").strip
        file_path = row.at(5).to_s("latin1")
        file_name = file_path.split("/")[-1]
        file_size = File.size("c:/www/gai/rubberdoc/"+file_name)
        
        
          puts "insert into jos_rubberdoc_docs(category_id, file,file_size, title, alias,published,access,description,created) values("+categ[category].to_i.to_s+",'"+file_name+"',"+file_size.to_s+",'"+entry+"','"+entry.gsub(" ", "-")+"',1,1,'"+entry+"','"+date.strftime("%Y-%m-%d")+"');"
        
      }
      
    end
    
end
