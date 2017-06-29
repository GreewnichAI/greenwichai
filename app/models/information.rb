require 'fastercsv'
class Information < ActiveRecord::Base
  Universe = ["Primary Strategy", "Secondary Strategy", "Regional Focus", "Country Focus", "All Funds"]
  
  Period  = {
              "1M" => "lmr",
              "3M" => "cr_3",
              "YTD"=> "f_ytd",
              "1Y" => "car_12",
              "3Y" => "car_36",
              "5Y" => "car_60"
            }
  
  set_table_name "information"
  has_attached_file :att1
  has_attached_file :att2
  has_attached_file :att3
  has_attached_file :att4
  belongs_to :manager

  has_many :peer_portfolios  

  has_many :performances, :foreign_key=>"id_1", :primary_key=>"id_1"
#validates :CIK, in: 5..5, allow_blank: true
#validates :CIK, length: {is: 5}, allow_blank: true
validates_length_of :CIK, :minimum => 10, :allow_blank => true  
  # Scopes
  named_scope :is_fresh, :conditions => 'is_fresh is true'
  # named_scope :master, :conditions => ["upper(F20) not like ? and upper(F20) not like ? and upper(F20) not like ? and upper(F20) not like ? and F51 like ?", "%DELETE%", "%WRI%","%DUPLICATE%","%DEFUNCT%", "Master List"]
  named_scope :master, :conditions => ["f51='Master List'"]

  named_scope :primary, (lambda do |strategy| 
    {:conditions => ['f37 = ?', strategy]}
  end)
  
  named_scope :secondary, (lambda do |strategy| 
    {:conditions => ['f39 = ?', strategy]}
  end)
  
  named_scope :regional, (lambda do |strategy|
    {:conditions => ['f40 = ?', strategy]}
  end)
  
  named_scope :country, (lambda do |strategy| 
    {:conditions => ['f38 = ?', strategy]}
  end)
  
  named_scope :return_reported, (lambda do |duration| 
    {
      :conditions => ["performance.return is not null and performance.date_1 >= ?", duration.months.ago(Time.now).beginning_of_month],
      :joins => "INNER JOIN performance ON performance.id_1 = information.id_1"
    }
  end)

  named_scope :durat, (lambda do |dur| 
    {
      :conditions => "",
      :select     => "information.cr_3, information.lmr, information.f_ytd, information.car_12, information.car_36, information.car_60, information.id, information.id_1"
    }
  end)  
  
 	def set_strategies(f49)
 		if f49=="Long/Short Equity - Growth"
 			# group - self.f15
 			# primary - f37
 			# secondary - f39
 			self.f15 = "Long-Short Equity Group"
 			self.f37 = "Long-Short Equity"
 			self.f39 = "Growth"
 		elsif f49=="Long/Short Equity - Value"
 			self.f15 = "Long-Short Equity Group"
 			self.f37 = "Long-Short Equity"
 			self.f39 = "Value"
 		elsif f49=="Long/Short Equity - Opportunistic"
 			self.f15 = "Long-Short Equity Group"
 			self.f37 = "Long-Short Equity"
 			self.f39 = "Opportunistic"
 		elsif f49=="Short-Biased"
 			self.f15 = "Long-Short Equity Group"
 			self.f37 = "Long-Short Equity"
 			self.f39 = "Short-Biased"
 		elsif f49=="Equity Market Neutral"
 			self.f15 = "Market Neutral Group"
 			self.f37 = "Equity Market Neutral"
      self.f39 = ""
 		elsif f49=="Convertible Arbitrage"
 			self.f15 = "Market Neutral Group"
 			self.f37 = "Arbitrage"
 			self.f39 = "Convertible Arbitrage"
 		elsif f49=="Merger Arbitrage"
 			self.f15 = "Market Neutral Group"
 			self.f37 = "Event-Driven"
 			self.f39 = "Merger Arbitrage"
 		elsif f49=="Fixed Income Arbitrage"
 			self.f15 = "Market Neutral Group"
 			self.f37 = "Arbitrage"
 			self.f39 = "Fixed Income Arbitrage"
 		elsif f49=="Long-Short Credit"
 			self.f15 = "Specialty Strategies Group"
 			self.f37 = "Long-Short Credit"
      self.f39 = ""
 		elsif f49=="Multiple Arbitrage Strategies"
 			self.f15 = "Market Neutral Group"
 			self.f37 = "Arbitrage"
 			self.f39 = "Several Arb Strategies"
 		elsif f49=="Distressed Securities"
 			self.f15 = "Market Neutral Group"
 			self.f37 = "Event-Driven"
 			self.f39 = "Distressed Securities"
 		elsif f49=="Multiple Event-Driven Strategies"
 			self.f15 = "Market Neutral Group"
 			self.f37 = "Event-Driven"
 			self.f39 = "Diversified Event-Driven"
 		elsif f49=="Macro"
 			self.f15 = "Directional Trading Group"
 			self.f37 = "Macro"
      self.f39 = ""
 		elsif f49=="Futures - Systematic"
 			self.f15 = "Directional Trading Group"
 			self.f37 = "Futures"
 			self.f39 = "Systematic"
 		elsif f49=="Futures - Discretionary"
 			self.f15 = "Directional Trading Group"
 			self.f37 = "Futures"
 			self.f39 = "Discretionary"
 		elsif f49=="Multi-Strategy"
 			self.f15 = "Specialty Strategies Group"
 			self.f37 = "Multi-Strategy"
      self.f39 = ""
 		elsif f49=="Fund of Funds"
 			self.f15 = "Fund of Funds Group"
 			self.f37 = "Fund of Funds"
      self.f39 = ""
 		elsif f49=="Arbitrage - Other"
 			self.f15 = "Market Neutral Group"
 			self.f37 = "Arbitrage"
 			self.f39 = "Other Arbitrage"
 		end
 		self.save
	end

  def set_firm_aum(dt,val)
    id1s = [self] + self.other_funds_in_firm
    Performance.all(:conditions=>["date_1 like ? and id_1 in (?)",dt.to_s+"%",id1s.map{|c| c.id_1}]).each do |p|
      p.firm_aum = val.blank? ? nil : val
      p.save
    end
  end


	def other_funds_in_firm
		a = []
		ManagerToFund.find(:all, :conditions=>["manager_id = ?", self.firm.manager_id]).each do |mtf|
				i = Information.find(:first, :conditions=>["id_1 = ?", mtf.fund_id])
				a<<i if (!i.nil? and i.id!=self.id)
		end
		a
	end
  
  def refresh_aums
    i=self
    of = i.other_funds_in_firm.first
    of.performance_data.each do |pd|
      mpd = Performance.find(:first, :conditions=>["date_1 like ? and id_1 = ?", pd.date_1,i.id_1])
      if !mpd.nil? and mpd.firm_aum !=pd.firm_aum
        mpd.firm_aum = pd.firm_aum
        mpd.save
      end
    end
  end
  
  def performance_data(extra_cond="", ord="date_1")
  	ps = Performance.find(:all, :conditions=>["id_1=? "+extra_cond,self.attributes["id_1"]], :order=>ord)
  	if ps.size>0
  		lp = Performance.find(:first, :conditions=>["id_1=? and date_1 < ? and date_1 < ?",self.attributes["id_1"],ps.first.date_1, ps.last.date_1], :order=>"date_1 desc")
  	else
  		lp = nil
  	end
  	if !lp.nil?
  		lv = lp.nav.to_f
  	else
  		lv = self.systemcontrol.nav.to_f
  	end
  	
  	b = 0
  	psr = []
  	ps.each do |p|
  		if p.nav.to_f == 0
  			b = 1
  		end
  		if !lv.nil?
  			cl = p.nav.to_f / lv
  			p.write_attribute("calc_ret",cl-1)
  		else
  			p.write_attribute("calc_ret",nil)
  		end
  		lv = p.nav.to_f
  		psr << p
  	end
  	if b==0
  		pzr = []
  		psr.each do |p|
	  		p.write_attribute('return', p.calc_ret)
	  		pzr << p
  		end
  		psr = pzr
  	end
  	psr
	end
  
  def ytd2
    #perfs = Performance.all(:conditions=>["id_1 = ? and date_1 between ? and ? and `return`!=''", self.id_1, Time.now.strftime("%Y-01-01"), Time.now.strftime("%Y-%m-%d")], :order=>:date_1)
    lastnav = DailydataDay.first(:conditions=>["id_1 = ? and `return`!=''", self.id_1], :order=>"date_1 desc").nav
    firstnav = Performance.first(:conditions=>["id_1 = ? and date_1 between ? and ?", self.id_1, (Time.now-1.year).strftime("%Y-12-01"), (Time.now-1.year).strftime("%Y-12-31 23:59:59") ]).nav
    (lastnav.to_f-firstnav.to_f)/firstnav.to_f
  end
  
  def itd2
    #perfs = Performance.all(:conditions=>["id_1 = ? and date_1 between ? and ? and `return`!=''", self.id_1, Time.now.strftime("%Y-01-01"), Time.now.strftime("%Y-%m-%d")], :order=>:date_1)
    lastnav = DailydataDay.first(:conditions=>["id_1 = ? and `return`!=''", self.id_1], :order=>"date_1 desc").nav
    firstnav = Performance.first(:order=>"date_1", :conditions=>["id_1 = ? and `return` != '' and date_1 between ? and ?", self.id_1, "2008-09-01", (Time.now).strftime("2008-09-31 23:59:59") ])
    if firstnav.nil?
      firstnav = 100 
    else
      firstnav = firstnav.nav.to_f
    end
    
    (lastnav.to_f-firstnav.to_f)/firstnav.to_f
  end
  
  def ytd(yr=Time.now.year)
  	lp = Performance.find(:first, :conditions=>["id_1=?",self.attributes["id_1"]], :order=>"date_1 desc", :limit=>1)
  	if !lp.nil? and !lp.date_1.nil?
  		if lp.date_1.year<yr
  			yr = lp.date_1.year
  		end 
  	end
    if self.f21.nil?
      inception_date = "1980-01-01"
    else
      inception_date = self.f21.strftime("%Y-%m-%d")
    end
  	#ps = Performance.find(:all, :conditions=>["ID_1 = ? and date_1 like ?", self.attributes["id_1"], yr.to_s+"-%"], :order=>"date_1")
  	ps = self.performance_data(" and date_1 > '#{inception_date}' and date_1 like '"+yr.to_s+"-%'")
  	ret_ytd = 100.to_f
  	ps.each do |p|
  		ret_ytd = (1+(p.return.to_s.gsub(",",".").to_f))*ret_ytd
  	end
  	return ret_ytd.round(2)-100
	end
	
	def cummulative
		#ps = Performance.find(:all, :conditions=>["ID_1 = ?", self.attributes["id_1"]], :order=>"date_1")
    if self.f21.nil?
      inception_date = "1980-01-01"
    else
      inception_date = self.f21.strftime("%Y-%m-%d")
    end
		ps = self.performance_data(" and date_1 > '#{inception_date}'")
  	ret_ytd = 100.to_f
  	ps.each do |p|
  		ret_ytd = (1+(p.return.to_s.gsub(",",".").to_f))*ret_ytd
  	end
  	return ret_ytd.round(2)-100
	end
	def ann_cummulative
		#ps = Performance.find(:all, :conditions=>["ID_1 = ?", self.attributes["id_1"]], :order=>"date_1")
		if self.f21.nil?
      inception_date = "1980-01-01"
    else
      inception_date = self.f21.strftime("%Y-%m-%d")
    end
		ps = self.performance_data(" and date_1 > '#{inception_date}'")
		v_no = 0 
		ps.each do |p|
			v_no = v_no + 1 if p.return.to_s.gsub(",",".").to_f!=0
		end
  	ret_ytd = self.cummulative / 100
  	vl = 0
  	a1 = (1+ret_ytd.to_f)
  	b1 = (1.to_f/v_no)
  	k1 = 1
  	k1 = -1 if a1<0
  	vl = ((((k1*(a1.abs**b1))**12)-1)*100).round(2) if v_no>0
  	return vl
	end
  
  def last_aum
    lp=Performance.find(:first, :conditions=>"Id_1 = "+self.id_1.to_s+" and fundsmanaged!='0'", :order=>"date_1 desc")
    #lp = self.performance_data(" and fundsmanaged!='0'", "date_1 desc")
    rt = 0
    if !lp.nil?
      rt = (lp.fundsmanaged.to_s.gsub(",","").to_f/1000000).round(2)
      si1 = self.systeminformation1
      si1.f27 = rt
      si1.save
    end
    return rt
  end
  
  def last_firm_aum
    lp=Performance.find(:first, :conditions=>"Id_1 = "+self.id_1.to_s+" and firm_aum!='0' and firm_aum!=''", :order=>"date_1 desc")
    #lp = self.performance_data(" and firm_aum!='0'", "date_1 desc")
    rt = 0
    if !lp.nil?
      rt = (lp.firm_aum.to_s.gsub(",","").to_f/1000000).round(2)
      if !rt.nil? and rt.to_f!=0
          si1 = self.systeminformation1
          si1.f35 = rt
          si1.save
      end
    end
    return rt
  end
  
  def month_data(tm=Time.now, real_val = 1)
    p = Performance.first(:conditions=>["id_1 = ? and date_1 between ? and ?", self.id_1, tm.strftime("%Y-%m-01 00:00:00"), tm.end_of_month.strftime("%Y-%m-%d 23:59:59")])
    return (p.nil? ? nil : (real_val ==1 ? p.return : (p.return.to_f*100).round(2)))
  end 
  
  def mtd_data
    arr = DailydataDay.find(:all, :order=>:date_1, :conditions=>["id_1 = ? and date_1 between ? and ? and `nav` !=''", self.id_1, (Time.now-1.day).strftime("%Y-%m-01 00:00:00"), (Time.now-1.day).end_of_month.strftime("%Y-%m-%d 23:59:59")]).map{|c| c.nav }
    if arr.size>0
    lp=DailydataDay.all(:conditions=>["id_1 = ? and date_1 like ? and `nav`!='' and `nav` is not null", self.id_1, (Time.now-1.month).strftime("%Y-%m-")+"%"], :order=>"date_1").last
    ini_nav = 100
    ini_nav = lp.nav if !lp.nil?
    #arr[-1]=ini_nav
    retz = []
    (0..(arr.size-1)).each do |i|
      if i==0
        arn = ini_nav.to_f
      else
        arn = arr[i-1].to_f
      end
      
      retz << (arr[i].to_f - arn)/arr[i].to_f
      
    end
    else    
      retz = DailydataDay.find(:all, :conditions=>["id_1 = ? and date_1 between ? and ? and `return` !=''", self.id_1, Time.now.strftime("%Y-%m-01 00:00:00"), Time.now.end_of_month.strftime("%Y-%m-%d 23:59:59")]).map{|c| c.return }
    end
    retz
    #ini_nav = Performance.find(:first, :conditions=>["id_1=? and date_1 like ?", self.id_1,(Time.now-1.month).strftime("%Y-%m-")+"%"]).nav.to_f
    #i=3; (arr[i].to_f - arr[i-1].to_f)/arr[i].to_f
    
  end
  
  def ytd_data(tm=Time.now)
    Performance.find(:all, :conditions=>["id_1 = ? and date_1 between ? and ? ", self.id_1, tm.strftime("%Y-01-01 00:00:00"), tm.end_of_month.strftime("%Y-%m-%d 23:59:59")]).map{|c| c.return }
  end
  
  def perf_data(tm=Time.now,lm=12)
    Performance.find(:all, :conditions=>["id_1 = ? and  date_1<=?", self.id_1, tm.end_of_month.strftime("%Y-%m-%d 23:59:59")], :order=>"date_1 desc", :limit=>lm).map{|c| c.return }
  end
  
  
  def yr1_data(tm=Time.now)
    Performance.find(:all, :conditions=>["id_1 = ? and  date_1<?", self.id_1, tm.end_of_month.strftime("%Y-%m-%d 23:59:59")], :order=>"date_1 desc", :limit=>12).map{|c| c.return }
  end
  
  def mon3_data(tm=Time.now)
    Performance.find(:all, :conditions=>["id_1 = ? and  date_1<?", self.id_1, tm.end_of_month.strftime("%Y-%m-%d 23:59:59")], :order=>"date_1 desc", :limit=>3).map{|c| c.return }
  end
  
  def itd_data
        Performance.find(:all, :conditions=>["id_1 = ? and date_1 between ? and ? and `return` !=''", self.id_1, Time.now.strftime("2008-10-01 00:00:00"), Time.now.end_of_month.strftime("%Y-%m-%d 23:59:59")], :group=>"id_1,date_1").map{|c| c.return }
  end
  
  def all_data
      Performance.find(:all, :conditions=>["id_1 = ? and date_1 between ? and ? and `return` !=''", self.id_1, Time.now.strftime("1960-01-01 00:00:00"), Time.now.end_of_month.strftime("%Y-%m-%d 23:59:59")]).map{|c| c.return }
  end
  
  def self.perf_data(arr,tm=Time.now,lm=0)
    Performance.all(:conditions=>["id_1 in (?) and date_1 between ? and ?", arr, (tm-lm.months).strftime("%Y-%m-01 00:00:00"),tm.end_of_month.strftime("%Y-%m-%d 23:59:59")], :group=>"id_1", :select=>"id_1,avg(`return`) as `return`").map{|c| c.return}
  end
  
  def self.month_data(tm=Time.now)
      Performance.find(:all, :conditions=>["date_1 between ? and ? and `return` !=''", tm.strftime("%Y-%m-01 00:00:00"), tm.end_of_month.strftime("%Y-%m-%d 23:59:59")]).map{|c| c.return }
  end
  
  def self.cummulative(arr)
    td = 1
    arr.each do |i|
      td = td * (i.to_f+1)
    end
    ((td-1)*100)
  end
  
  def self.vamin(arr,vami0=1000)
    vami = vami0
    arr.each do |i|
      vami = vami * (i.to_f+1)
    end
    vami
  end
  
  def self.car(arr,vami0=1000)
    vamien = self.vamin(arr,vami0) 
    rap = (vamien/ vami0) 
    oneoversize = (1.to_f/arr.size)
    pow12 = ((( rap ** oneoversize)**12)-1)
    (pow12*100).to_d.round(2)
  end
  
  def mtd 
     #Information.cummulative(self.mtd_data) 
     mtdv  = 0
      z1=DailydataDay.all(:conditions=>["id_1=? and nav!=''", self.id_1], :order=>"date_1 desc", :limit=>1)[0]
      if !z1.nil?
        lp=DailydataDay.all(:conditions=>["id_1 = ? and date_1 like ? and `nav`!='' and `nav` is not null", self.id_1, (z1.date_1-1.month).strftime("%Y-%m-")+"%"], :order=>"date_1").last
        ini_nav = lp.nav
        mtdv = (z1.nav.to_f - ini_nav.to_f)/ini_nav.to_f
      end
=begin     
    arr = DailydataDay.find(:all, :order=>:date_1, :conditions=>["id_1 = ? and date_1 between ? and ? and `nav` !=''", self.id_1, (Time.now-1.day).strftime("%Y-%m-01 00:00:00"), (Time.now-1.day).end_of_month.strftime("%Y-%m-%d 23:59:59")]).map{|c| c.nav }
    mtdv  = 0 
    if arr.size>0
    lp=DailydataDay.all(:conditions=>["id_1 = ? and date_1 like ? and `nav`!='' and `nav` is not null", self.id_1, (Time.now-1.month).strftime("%Y-%m-")+"%"], :order=>"date_1").last
    ini_nav = 100
    ini_nav = lp.nav if !lp.nil?
    mtdv = (arr.last.to_f - ini_nav.to_f)/ini_nav.to_f
    end
=end    
    return mtdv
  end
  
  def dtd
    arr = DailydataDay.find(:all, :order=>"date_1 desc", :conditions=>["id_1 = ? and date_1 between ? and ? and `nav` !=''", self.id_1, (Time.now-10.day).strftime("%Y-%m-%d 00:00:00"), (Time.now).strftime("%Y-%m-%d 23:59:59")])
    nav = 100
    nav = arr[1].nav.to_f if !arr[1].nil?
    
    (arr[0].nav.to_f - nav) / nav
  end
  
  def self.avg(arr)
    n = 0
    arr.each do |i|
      n = n + i.to_f
    end
    n.to_f/arr.size
  end
  
  def self.std(arr)
    mr = Information.avg(arr)
    n = 0
    arr.each do |i|
      n = n + (((i.to_f-mr)**2)  / (arr.size - 1 ))
    end
    (((n**0.5)*(Math.sqrt(12)))*100).round(2)
  end
  
  
  
  
  
  
  
  
  
  
  
  ############ MODEL FIXES
  
  def make_init
  	self.usercheck2
  	self.usercheck7
  	self.systemcheck1
  	self.systemcheck5
  	self.userinformation1
  	self.userinformation2
  	self.userinformation3
  	self.userinformation4
  	self.systeminformation1
  	self.systeminformation2
  	self.systeminformation5
  	self.usermemo1
    self.mastername
	end
 
  
  
  def firm
  	mtf = ManagerToFund.find(:first, :conditions=>["fund_id = ?", self.id_1])
  	firm = ManagerInformation.new
  	if !mtf.nil?
  		firm = ManagerInformation.find(:first, :conditions=>["manager_id = ? ",mtf.manager_id])
  	end
  	return firm
	end

  def mastername
    mastername = Mastername.find(:first, :conditions=>["ID_1 = ?", self.attributes["id_1"]])
		if mastername.nil?
			mastername = Mastername.new
			mastername.id_1 = self.id_1
      mastername.mastername = self.f20
			mastername.save
		end
		return mastername 
  end
  

  def usermemo1
		um1 = Usermemo1.find(:first, :conditions=>["ID_1 = ?", self.attributes["id_1"]])
		if um1.nil?
			um1 = Usermemo1.new
			um1.id_1 = self.id_1
			um1.datavendorid=self.datavendorid
			um1.lastupdated = Time.now
			um1.datavendorname = self.datavendorname
			um1.save
		end
		return um1 
	end

	def usercheck2
		uc2 = Usercheck2.find(:first, :conditions=>["ID_1 = ?", self.attributes["id_1"]])
		if uc2.nil?
			uc2 = Usercheck2.new
			uc2.id_1 = self.id_1
			uc2.datavendorid=self.datavendorid
			uc2.lastupdated = Time.now
			uc2.datavendorname = self.datavendorname
			uc2.save
		end
		return uc2 
	end
	
  
  
	def usercheck7
		uc7 = Usercheck7.find(:first, :conditions=>["ID_1 = ?", self.attributes["id_1"]])
		if uc7.nil?
			uc7 = Usercheck7.new
			uc7.id_1 = self.id_1
			uc7.save
		end
		return uc7
	end
	
	def userinformation1
		ui1 = Userinformation1.find(:first, :conditions=>["ID_1 = ?", self.attributes["id_1"]])
		if ui1.nil?
			ui1 = Userinformation1.new
			ui1.id_1 = self.id_1
			ui1.datavendorid=self.datavendorid
			ui1.lastupdated = Time.now
			ui1.datavendorname = self.datavendorname
			ui1.f20 = Time.now.strftime("%m/%d/%y")
			ui1.save
		end
		return ui1 
	end
	
	def userinformation2
		ui1 = Userinformation2.find(:first, :conditions=>["ID_1 = ?", self.attributes["id_1"]])
		if ui1.nil?
			ui1 = Userinformation2.new
			ui1.id_1 = self.id_1
			ui1.datavendorid=self.datavendorid
			ui1.lastupdated = Time.now
			ui1.datavendorname = self.datavendorname
			ui1.save
		end
		return ui1 
	end
	
	def userinformation3
		ui1 = Userinformation3.find(:first, :conditions=>["ID_1 = ?", self.attributes["id_1"]])
		if ui1.nil?
			ui1 = Userinformation3.new
			ui1.id_1 = self.id_1
			ui1.datavendorid=self.datavendorid
			ui1.lastupdated = Time.now
			ui1.datavendorname = self.datavendorname
			ui1.save
		end
		return ui1 
	end
	
	def userinformation4
		ui1 = Userinformation4.find(:first, :conditions=>["ID_1 = ?", self.attributes["id_1"]])
		if ui1.nil?
			ui1 = Userinformation4.new
			ui1.id_1 = self.id_1
			ui1.datavendorid=self.datavendorid
			ui1.lastupdated = Time.now
			ui1.datavendorname = self.datavendorname
			ui1.save
		end
		return ui1 
	end
	
	def systemcontrol
  	ui1 = Systemcontrol.find(:first, :conditions=>["ID_1 = ?", self.attributes["id_1"]])
		if ui1.nil?
			ui1 = Systemcontrol.new
			ui1.id_1 = self.id_1
			#ui1.datavendorid=self.datavendorid
			#ui1.lastupdated = Time.now
			#ui1.datavendorname = self.datavendorname
			ui1.nav = 100
			ui1.save
		end
		return ui1 
	end
	
	def systeminformation1
  	ui1 = Systeminformation1.find(:first, :conditions=>["ID_1 = ?", self.attributes["id_1"]])
		if ui1.nil?

			sio1 = Systeminformation1.find(:first, :conditions=>["id_1 in (?) and f35>0",self.other_funds_in_firm.map{|c| c.id_1} ])
			ui1 = Systeminformation1.new
			ui1.id_1 = self.id_1
			ui1.datavendorid=self.datavendorid
			ui1.lastupdated = Time.now
			ui1.datavendorname = self.datavendorname
			ui1.f35 = sio1.f35 if !sio1.nil?
			ui1.save
		end
		return ui1 
	end
	
	def systeminformation2
  	ui1 = Systeminformation2.find(:first, :conditions=>["ID_1 = ?", self.attributes["id_1"]])
		if ui1.nil?
			ui1 = Systeminformation2.new
			ui1.id_1 = self.id_1
			ui1.datavendorid=self.datavendorid
			ui1.lastupdated = Time.now
			ui1.datavendorname = self.datavendorname
			
			ui1.save
		end
		return ui1 
	end
	
	def systeminformation5
  	ui1 = Systeminformation5.find(:first, :conditions=>["ID_1 = ?", self.attributes["id_1"]])
		if ui1.nil?
			ui1 = Systeminformation5.new
			ui1.id_1 = self.id_1
			ui1.datavendorid=self.datavendorid
			ui1.lastupdated = Time.now
			ui1.datavendorname = self.datavendorname
			ui1.save
		end
		return ui1 
	end
  
  def systemcheck1
		uc7 = Systemcheck1.find(:first, :conditions=>["ID_1 = ?", self.attributes["id_1"]])
		if uc7.nil?
			uc7 = Systemcheck1.new
			uc7.id_1 = self.id_1
			uc7.save
		end
		return uc7
	end
	
	def systemcheck5
		uc7 = Systemcheck5.find(:first, :conditions=>["ID_1 = ?", self.attributes["id_1"]])
		if uc7.nil?
			uc7 = Systemcheck5.new
			uc7.id_1 = self.id_1
			uc7.save
		end
		return uc7
	end

  def strategy_mapping(fund_group)
    if fund_group == "Long-Short Equity Group"
      strategy_val = f39
    elsif fund_group == "Market Neutral Group"
      strategy_val = f39
      strategy_val ||= f37
    else 
      strategy_val = f37
    end
    return strategy_val
  end

  def strategy_calcs(stat_type, perf_date = nil)
    strategy_calcs_setup =  {
                              "Futures" => {
                                              "Discretionary" => 250,
                                              "Systematic"    => 250
                                           },
                              "Long-Short Equity" => {
                                                        "Value" => 257,
                                                        "Growth" => 254,
                                                        "Opportunistic" => 4268,
                                                        "Short-Biased"  => 4264
                                                     },
                              "Arbitrage" => {
                                              "Arbitrage-Other" => 4263,
                                              "Convertible Arbitrage"  => 255,
                                              "Several Arb Strategies" => 4263
                                             },
                              "Equity Market Neutral" => 247,
                              "Fund of Funds"     => 188,
                              "Event-Driven"      => {
                                                        "Merger Arbitrage" => 4273,
                                                        "Diversified Event-Driven" => 262,
                                                        "Distressed Securities" => 251
                                                      },
                              "Long-Short Credit" => 4275,
                              "Multi-Strategy"    => 4267,
                              "Macro"             => 4269
                            }
    f_37            = strategy_calcs_setup[f37]
    if f_37
      if f_37.class.to_s != "Fixnum"
        if strategy_calcs_setup[f37].has_key?(f39)
          index_id    = strategy_calcs_setup[f37][f39]
        else
          return 0.0
        end
      else
        index_id    = f_37
      end
      strategy_index_fund = Information.find_by_id_1(index_id)
      if strategy_index_fund
        if stat_type == 'lmr'
          if perf_date
            date1 = perf_date.to_date.beginning_of_month.strftime("%Y-%m-%d 00:00:00")
            date2 = perf_date.to_date.at_end_of_month.strftime("%Y-%m-%d 00:00:00")
            perf_data = Performance.all(:conditions => "performance.id_1 = #{strategy_index_fund.id_1} and date_1 between '#{date1}' and '#{date2}' and performance.return is not null")
            perf_return = perf_data.first.return if perf_data.count > 0
            perf_return ||= 0.0
            return perf_return
          end
          return 0.0
        else
          return strategy_index_fund.send(stat_type)         
        end
      else
        return 0.0
      end
    else
      return 0.0
    end
  end  
	
  # fetch universe drop-down data for the information fund
  def universe_selector
    options_for_universe = []

    options_for_universe << "All Funds"                   unless f51.blank?
    options_for_universe << "Primary Strategy: #{f37}"    unless f37.blank?
    options_for_universe << "Secondary Strategy: #{f39}"  unless f39.blank?
    options_for_universe << "Regional Focus: #{f40}"      unless f40.blank?
    options_for_universe << "Country Focus: #{f38}"       unless f38.blank?
    
    options_for_universe
  end
  
  # fetch universe list as per the selected universe
	def fetch_universe(selected)
	  if selected == "Primary Strategy: #{f37}"
	    universes = Information.master.primary(f37).return_reported(3)
	  elsif selected == "Secondary Strategy: #{f39}"
	    universes = Information.master.secondary(f39).return_reported(3)
	  elsif selected == "Regional Focus: #{f40}"
	    universes = Information.master.regional(f40).return_reported(3)
	  elsif selected == "Country Focus: #{f38}"
	    universes = Information.master.country(f38).return_reported(3)
	  else
	    universes = Information.master.return_reported(3)
    end
	end
	
	def self.primary_benchmark
	 p_bm_indices = [4274, 4270, 255, 256, 251, 262, 247, 248, 249, 188, 250, 254, 4275, 4276, 4269, 4271, 4273, 4267, 4268, 4263, 4264, 263, 257, 14186, 14168, 14167, 14169, 14166, 246, 14173, 14172, 14170]
	 p_bm_indices_r = Information.find(:all, :conditions => {:id_1 => p_bm_indices}, :select => 'id_1, f20').index_by(&:id_1)
	 # p_bm_indices.collect {|i| Information.find_by_id_1(i)}
   return p_bm_indices_r
	end
	
	def self.secondary_benchmark
	 s_bm_indices = [173, 164, 12313, 15635, 15637, 15638, 15639, 205, 15641, 15637, 15638, 5171, 170, 15640, 4274, 4270, 255, 256, 251, 262, 247, 248, 249, 188, 250, 254, 4275, 4276, 4269, 4271, 4273, 4267, 4268, 4263, 4264, 263, 257, 14186, 14168, 14167, 14169, 14166, 246, 14173, 14171, 14172, 14170]
   # Information.find(:all, :conditions => {:id_1 => s_bm_indices})
   # s_bm_indices.collect {|i| Information.find_by_id_1(i)}
   s_bm_indices_r = Information.find(:all, :conditions => {:id_1 => s_bm_indices}, :select => 'id_1, f20').index_by(&:id_1)
   return s_bm_indices_r
	end
	
	def percentile_position(pos, universe_arr)
	  position = ((universe_arr.count + 1)*(pos/100)).ceil
	  position = position - 1 if position > universe_arr.count
	  universe_arr[position - 1]
	end
	
	def get_empty_data(arr)
	  arr << 0.00
	  arr << 0.00
	  arr << 0.00
	  arr << 0.00
	  arr << 0.00
	  
	  arr
	end
	
	def min(arr)
	  arr.compact.min
	end
	
	def max(arr)
	 arr.compact.max
	end
	
  def get_percentile(p_pos, arr_of_universe, return_name)
	  position = ((arr_of_universe.count + 1)*(p_pos/100))
    
    a = position >= 1 ? arr_of_universe[position.floor - 1] :  arr_of_universe[0]
    b = position <= arr_of_universe.count ? arr_of_universe[position.ceil - 1] : arr_of_universe.last
  
	  a = a ? a.send(return_name) : 0.00
	  b = b ? b.send(return_name) : 0.00
  
    f_function = position - position.floor

    # added interpolation to get accurate results. 
    # The values might be different then what excel returns 
    # since it returns the value closest to the index    
  
    interpolate(a, b, f_function)#.round(2)
	end

  # added interpolation to get accurate results. 
  # The values might be different then what excel returns 
  # since it returns the value closest to the index
	
	def interpolate(a, b, f)
	  return a + f * (b - a)
	end
	
	def get_period_info(period)
	  arr             = []
	  return_name     = Period[period]
    universes       = @universes.durat(return_name)
    universes       = @universes.uniq
    universes       = universes.reject{|r| r.send(return_name).blank?}
	  arr_of_universe = universes.sort_by{|u| u.send(return_name)}

	  arr  << period                  # Time Period
	  arr  << @p_bm.send(return_name) # Benchmark1
	  arr  << @s_bm.send(return_name) # Benchmark2
	  arr  << self.send(return_name)  # Product
	  
	  if arr_of_universe and !arr_of_universe.empty?
      arr <<  get_percentile(5.00,  arr_of_universe, return_name) # 5th Percentile
      arr <<  get_percentile(25.00, arr_of_universe, return_name) # 25th Percentile
      arr <<  get_percentile(50.00, arr_of_universe, return_name) # 50th Percentile
      arr <<  get_percentile(75.00, arr_of_universe, return_name) # 75th Percentile
      arr <<  get_percentile(95.00, arr_of_universe, return_name) # 95th Percentile
    else
      arr << 0.00
  	  arr << 0.00
  	  arr << 0.00
  	  arr << 0.00
  	  arr << 0.00
    end
    
    arr
	end

	
	#############################################
	# Percentile Calculations
	#   Position of a percentile : 
	#      Ly = (n+1)*(y/100)
  #   y is percentile in consideration
  #   n is number of funds in universe selected
	#############################################
	def evaluate_report_data(review)
	  data        = []
	  chartData   = []
	  
	  lowest      = 0.0
	  highest     = 0.0
	  @p_bm       = Information.find_by_id_1(review[:p_bm])
    @s_bm       = Information.find_by_id_1(review[:s_bm])

    debugger
    @universes  = fetch_universe(review["universe"])

	  ["1M", "3M", "YTD", "1Y", "3Y", "5Y"].each do |key|
  	  data      = get_period_info(key)
  	  chartData << data
  	  lowest    = min(data[1..-1]) if lowest  > min(data[1..-1])
  	  highest   = max(data[1..-1]) if highest < max(data[1..-1])
  	end
    
    if lowest >= -25.0 and highest <= 25.0
      chartData << ["markers", 5]
    else
      low_diff =  lowest < -25.0 ? (lowest.abs - 25.0) : 0.0
      hig_diff =  highest > 25.0 ? (highest.abs - 25.0) : 0.0
      total = low_diff + hig_diff + 10
      
      if total > 0.0
        diff = (total/9.0).ceil
        chartData << ["markers", 5+diff]
      else
        chartData << ["markers", 5]
      end
    end
	  chartData
	end

  # My Funds Section

  def self.risk_dashboard_snapshot(ffunds, optns = nil)
    risk_dashboard_snapshot_json = {}
    ffunds.each do |fund_group|
      risk_dashboard_snapshot_json[fund_group[0]] = []
      fund_group[1].each do |fund|
        perf_data = fund.performance_data(" and performance.return is not null")
        perf_date = perf_data.last.date_1 if perf_data.count > 0
        fund_strategy = 0.0

        s_lmr = fund.strategy_calcs('lmr', perf_date) * 100.00
        s_f_ytd = fund.strategy_calcs('f_ytd')
        s_last_year_1 = fund.strategy_calcs('last_year_1')
        s_last_year_2 = fund.strategy_calcs('last_year_2')

        risk_dashboard_snapshot_json[fund_group[0]] <<[
                                                        fund.f20, 
                                                        fund.strategy_mapping(fund_group[0]), 
                                                        perf_date,
                                                        fund.lmr, 
                                                        s_lmr, 
                                                        (fund.lmr ? fund.lmr - s_lmr : nil), 
                                                        fund.f_ytd, 
                                                        s_f_ytd, 
                                                        (fund.f_ytd ? fund.f_ytd - s_f_ytd : nil),
                                                        fund.last_year_1, 
                                                        s_last_year_1, 
                                                        (fund.last_year_1 ? fund.last_year_1 - s_last_year_1 : nil), 
                                                        fund.last_year_2, 
                                                        s_last_year_2, 
                                                        (fund.last_year_2 ? fund.last_year_2 - s_last_year_2 : nil),
                                                        fund.id
                                                      ]
      end
      if optns and optns[:sort_by] and optns[:sort_by].to_i <= 14
        if optns[:order] == 'desc'
          risk_dashboard_snapshot_json[fund_group[0]] = 
            risk_dashboard_snapshot_json[fund_group[0]].sort {|x, y| (x[optns[:sort_by].to_i] || 0) <=> (y[optns[:sort_by].to_i] || 0)}
        else
          risk_dashboard_snapshot_json[fund_group[0]] = 
            risk_dashboard_snapshot_json[fund_group[0]].sort {|x, y| (y[optns[:sort_by].to_i] || 0) <=> (x[optns[:sort_by].to_i] || 0)}
        end
      end
    end
    risk_dashboard_snapshot_json = risk_dashboard_snapshot_json.sort {|x, y|  Portfolio.fund_group_order(x[0])<=>Portfolio.fund_group_order(y[0]) }
    return risk_dashboard_snapshot_json
  end

  def self.export_to_excel(data)
    headers = ['', '', '','']

    ["Last Month", "YTD", 1.year.ago(Date.today).strftime("%Y"), 2.year.ago(Date.today).strftime("%Y")].each do |col|
      headers << ['', col, ''] 
    end
    headers.flatten!
    sub_headers     = [ 'Fund Group',
                        'Fund Name', 'Strategy', 'Perf As Of:',
                        'Fund', 'Strategy', 'Diff',
                        'Fund', 'Strategy', 'Diff',
                        'Fund', 'Strategy', 'Diff',
                        'Fund', 'Strategy', 'Diff',
                        'Fund ID'
                      ]

    csv_data = FasterCSV.generate do |csv| 
      csv << headers if headers
      csv << sub_headers if sub_headers

      data.each do |fund_group, fund_group_data|
        fund_group_data.each do |fund|
          csv << [fund_group] + fund
        end 
      end
    end
  end

  def get_fund_graph_data
    greenwich = Information.find_by_id_1(4274)
    sp500     = Information.find_by_id_1(173)

    thisFund    = evaluateFund(self)
    if(!thisFund.empty?)
      @startDate  = thisFund.first[0]
      @endDate    = thisFund.last[0]
    end
    all_funds_data = {"fund" => thisFund, "gw" => evaluateFund(greenwich), "sp" => evaluateFund(sp500)}
    all_funds_data
  end

  def evaluateFund(ffund)
    data_series = []
    vami = 1000.0
    # performance_with_returns = ffund.performances.with_reported_return
    performance_with_returns = ffund.performance_data(" and performance.return is not null")
    performance_with_returns.each do |perf|
      if @startDate and @endDate
        if perf == performance_with_returns.first
          data_series << [@startDate, vami, @startDate.to_i*1000]
        else
          if perf.date_1 > @startDate and perf.date_1 <= @endDate
            vami = get_value_against_vami(vami, perf.return)
            data_series << [perf.date_1, vami, perf.date_1.to_i*1000]
          end
        end
      else
        if perf == performance_with_returns.first
          data_series << [perf.date_1, vami, perf.date_1.to_i*1000]
        else
          vami = get_value_against_vami(vami, perf.return)
          data_series << [perf.date_1, vami, perf.date_1.to_i*1000]
        end
      end
    end
    data_series
  end 
  
  def get_value_against_vami(vami, ror)
    vami * (1.0 + ror)
  end      

  def last_reported_month
    date =  Performance.first(:conditions=>["performance.return is not null and performance.id_1=?", self.id_1], :order=>"date_1 desc")
    if(date.nil? or date.date_1.nil?)
      nil
    else
      date.date_1
    end
  end

  # takes a number and options hash and outputs a string in any currency format
  def currencify(number, options={})
    # :currency_before => false puts the currency symbol after the number
    # default format: $12,345,678.90
    options = {:currency_symbol => "", :delimiter => ",", :decimal_symbol => ".", :currency_before => true}.merge(options)
    
    # split integer and fractional parts 
    int, frac = ("%.2f" % number).split('.')
    # insert the delimiters
    int.gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{options[:delimiter]}")
    
    if options[:currency_before]
      options[:currency_symbol] + int + options[:decimal_symbol] + frac
    else
      int + options[:decimal_symbol] + frac + options[:currency_symbol]
    end
  end  

  def aum_value(year)
    startYear = Date.new(year).to_time
    endYear   = startYear.at_end_of_year.to_time
    performance = self.performances.find(:first, :conditions=>["performance.return is not null and performance.return != '' and performance.date_1 >= ? and performance.date_1 <= ?", startYear, endYear], :order=>"date_1 desc")
    if performance
      aum = performance.fundsmanaged
      if aum.class == String
        aum = performance.fundsmanaged.gsub(',', '')
        return (aum.to_i == 0 ? "N/A" : "#{currencify(aum.to_f/1000000)} M")
      else
        return (aum ? "#{currencify(aum/1000000)} M" : "N/A")
      end
    else
      return "N/A"
    end
  end 

  def report
    collection_of_returns = []
    cur_year = Date.today.year
    oldest_year = self.f21.year #self.f21 > 5.year.ago(Date.today.beginning_of_year) ? self.f21.year : (5.year.ago(Date.today)).year
    # oldest_year = self.performance_data ? self.performance_data.first.date_1.year : self.f21.year
    yearly_report = []
    all_returns = []

    ((cur_year - oldest_year) + 1).times do |t_year|
      t_yearly_report = {}
      t_yearly_report[:year] = cur_year - t_year
      t_yearly_report[:perf] = {}

      t_year_perfs = self.performance_data(" and date_1 between '"+(cur_year - t_year).to_s+"-01-01' and '"+((cur_year - t_year)+1).to_s+"-01-01'")
      t_year_perfs.each do |perf|
        t_yearly_report[:perf][perf.date_1.strftime('%b')] = perf.return ? (perf.return*100.0).round(2) : nil
        all_returns << t_yearly_report[:perf][perf.date_1.strftime('%b')]
        collection_of_returns << t_yearly_report[:perf][perf.date_1.strftime('%b')]
      end

      yearly_report << t_yearly_report
    end
    chartReport = get_frequency_graph_data(all_returns)
    yearly_report << {:all_returns => chartReport}
    yearly_report
  end

  def get_frequency_graph_data(all_returns)
    frequency_graph_data = []

    all_returns = all_returns.compact

    if all_returns.length > 0
      sum = 0
      min = all_returns.min
      max = all_returns.max    

      min ||= 0.0
      max ||= 0.0

      min = min.ceil
      max = max.floor

      all_returns = all_returns.collect {|a| a.ceil if a}

      (min..max).each do |i|
        all_returns.each {|a| sum = sum+1 if a and a == i }
        frequency_graph_data << [i, sum]
        sum = 0
      end
    end

    return frequency_graph_data
  end           
end
