require 'pp'
#require 'win32ole'
#require 'access_db'
namespace :pertrac do
	
	def copy_table(table_name,db)
    puts "*** "+table_name
		cnt_debug = -1
		db.execute("delete from "+table_name+";")
    db.query("select * from "+table_name)
    db_field_types = db.field_types
    db_field_types["id_1"] = db_field_types["id"]
    db_field_types["date_1"] = db_field_types["date"]
    flds = []
    flds2 = []
    db.fields.each do |fld|
    	fld_name = fld
    	flds << fld_name.downcase
    	flds2 << fld_name.downcase.gsub(/^date$/, "[date]").gsub(/^return$/, "[return]")
    end
    
    cnt = 0 
    if table_name=="Performance"
      rez = ActiveRecord::Base.connection.execute("select * from "+table_name+" where ((`return` is not null and `return`!='') or fundsmanaged is not null or nav is not null or estimate is not null)" )
    else
        rez = ActiveRecord::Base.connection.execute("select * from "+table_name)
    end
      
		q = ""
		
		
		while row = rez.fetch_hash
			#row["lastupdated"] = Time.now.strftime("%Y-%m-%d")
			cnt = cnt + 1
			vls = []
			flds.each do |fld|
				fld_n=fld
				if fld=="id"
					fld_n = "id_1"
				elsif fld=="date"
					fld_n = "date_1"
				end
				r_id = fld
				r_v = row[fld_n]

						#vls << "'"+r_v.gsub("'","`")+"'" if !r_v.nil?
          	#vls << "NULL" if r_v.nil?
				#puts r_id+" "+r_v+" "+db_field_types[r_id].to_s
				if db_field_types[r_id]==11 # bool
						if r_v=="1"
							r_v = "-1"
						else
							r_v = "0"
						end
						vls << r_v
				elsif db_field_types[r_id]==5	# integer
						ins_v = r_v.to_s.gsub(",","").gsub("NaN","0")
						ins_v = "0" if ins_v.size==0
						vls << ins_v
				else												# other
						vls << "'"+r_v.gsub("'","`")+"'" if !r_v.nil?
          	vls << "NULL" if r_v.nil?
				end

			end
			
			q = "insert into "+table_name+"("+flds2.join(",")+") values("+vls.join(",")+");"
		
			begin
				
				db.execute(q)
				
			rescue
				puts "Error Here: "+Errno::ENOENT.new("#{$!}")
				puts q
				puts cnt
			end
			if cnt%5000==0
				puts table_name+": "+cnt.to_s
			end

			
		end
		puts "// "+cnt.to_s
		
		
=begin			
			vls = []
			row.each do |r_id,r_v|
        
        if !db.field_types[r_id.gsub(/_1$/,"")].nil?
        
				fld_name = r_id.gsub(/_1$/,"").gsub(/^date$/,"[date]").gsub(/^return$/, "[return]")
				flds << fld_name
				#puts fld_name + " " + db.field_types[r_id].to_s
				if db.field_types[r_id]==11 # bool
					if r_v=="1"
						r_v = "-1"
					else
						r_v = "0"
					end					
				end
				
#				if db.field_types[r_id]==7 and fld_name=="lastupdated" 
#					r_v = "1970-01-01" if r_v.nil?
#				end
				
				if db.field_types[r_id]==5	# integer
					ins_v = r_v.to_s.gsub(",","").gsub("NaN","0")
					ins_v = "0" if ins_v.size==0
					vls << ins_v
				else												# other
#					if fld_name=="datavendorname"
#						vls << "'"+r_v.gsub("'","`")+"'" if !r_v.nil?
#          	vls << "' '" if r_v.nil?
#					else
						vls << "'"+r_v.gsub("'","`")+"'" if !r_v.nil?
          	vls << "NULL" if r_v.nil?
#        	end
				end
       
      end if cnt>cnt_debug
        
			end
			q = "insert into "+table_name+"("+flds.join(",")+") values("+vls.join(",")+");"
			
			begin
				if cnt>cnt_debug
				db.execute(q)
				end
			rescue
				puts "Error Here: "+Errno::ENOENT.new("#{$!}")
				puts q
				puts cnt
			end
			if cnt%5000==0
				puts cnt
			end
			
		end
=end
	end
	
  task :clean => :environment do
    ActiveRecord::Base.connection.execute("UPDATE performance SET lastupdated=NOW() WHERE lastupdated IS NULL")
    ActiveRecord::Base.connection.execute("UPDATE information SET lastupdated=NOW() WHERE lastupdated IS NULL")
    clss = [Systeminformation1,Systeminformation2,Systeminformation5,Userinformation1,Userinformation2,Userinformation3,Userinformation4,Usercheck2,Systemcheck5,Systemcheck1]
    clss.each do |cls|
        puts "Cleaning: "+cls.class_name
        ui2=cls.find(:all, :conditions=>["datavendorid is null"])
          ui2.each do |ui|
          i = Information.find(:first, :conditions=>["id_1 = ?", ui.id_1])
          ui.datavendorid=i.datavendorid if !i.nil?
          ui.save
        end
        
        ActiveRecord::Base.connection.execute("update "+cls.class_name.to_s+" set lastupdated=NOW() where lastupdated is null")
        ActiveRecord::Base.connection.execute("update "+cls.class_name.to_s+" set datavendorname='VAN' where datavendorname is null")
        
    end
    m_ids = Mastername.all.map{|c| c.id_1 }
    i_ids = Information.all.map{|c| c.id_1 }
    
    Information.find(:all, :conditions=>["id_1 in (?)", i_ids-m_ids]).each do |i|
      m=Mastername.new
      m.id_1 = i.id_1
      m.mastername = i.f20
      m.save
    end
    
    #Information.all.each do |i|
        #i.f33 = i.last_aum
        #i.f34 = i.last_firm_aum
        #i.save
    #end
    
  end
  
  
	task :sync => :environment do
		db = AccessDb.new('d:\www\srip\pertrac_current.mdb')
		db.open
		cnt = 0
		    
		copy_table("Information", db)

		copy_table("Mastername", db)
    
    copy_table("SystemCheck1", db)
    copy_table("SystemCheck2", db)
    copy_table("SystemCheck3", db)
    copy_table("SystemCheck4", db)
    copy_table("SystemCheck5", db)
    copy_table("SystemCheck6", db)
    copy_table("SystemInformation1", db)
    copy_table("SystemInformation2", db)
    copy_table("SystemInformation3", db)
    copy_table("SystemInformation4", db)
    copy_table("SystemInformation5", db)
    copy_table("SystemInformation6", db)

    copy_table("UserCheck1", db)
    copy_table("UserCheck2", db)
    copy_table("UserCheck3", db)
    copy_table("UserCheck4", db)
    copy_table("UserCheck5", db)
    copy_table("UserCheck6", db)
    copy_table("UserInformation1", db)
    copy_table("UserInformation2", db)
    copy_table("UserInformation3", db)
    copy_table("UserInformation4", db)
    copy_table("UserInformation5", db)
    copy_table("UserInformation6", db)
    copy_table("LeverageData", db)
    copy_table("Performance", db)
    
		db.close
    
  end  
end
