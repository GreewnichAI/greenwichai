class GaiController < ApplicationController
  
def etf_list
  Settings.etf_list = params[:set][:etf_list] if params[:set]
  @set = Settings.etf_list
end

def rlist1
  render :layout=>false
end

def rlist2
  render :layout=>false
end

def listDailyUCITSIndices
  
  @globalIndex = DailydataDay.find(:all, :conditions =>'id_1 = 17056 and date_1 >= "'+Time.now.beginning_of_month().strftime('%Y-%m-%d %H:%M:%S')+'" and date_1 <= "'+Time.now.strftime('%Y-%m-%d %H:%M:%S')+'"', :order => "date_1 desc", :offset=> 1)
  @equity = DailydataDay.find(:all, :conditions =>'id_1 = 17058 and date_1 >= "'+Time.now.beginning_of_month().strftime('%Y-%m-%d %H:%M:%S')+'" and date_1 <= "'+Time.now.strftime('%Y-%m-%d %H:%M:%S')+'"', :order => "date_1 desc", :offset=> 1)
  @eventDrive = DailydataDay.find(:all, :conditions =>'id_1 = 17059 and date_1 >= "'+Time.now.beginning_of_month().strftime('%Y-%m-%d %H:%M:%S')+'" and date_1 <= "'+Time.now.strftime('%Y-%m-%d %H:%M:%S')+'"', :order => "date_1 desc", :offset=> 1)
  @arbitrage = DailydataDay.find(:all, :conditions =>'id_1 = 17057 and date_1 >= "'+Time.now.beginning_of_month().strftime('%Y-%m-%d %H:%M:%S')+'" and date_1 <= "'+Time.now.strftime('%Y-%m-%d %H:%M:%S')+'"', :order => "date_1 desc", :offset=> 1)
  @longShortEquity = DailydataDay.find(:all, :conditions =>'id_1 = 17062 and date_1 >= "'+Time.now.beginning_of_month().strftime('%Y-%m-%d %H:%M:%S')+'" and date_1 <= "'+Time.now.strftime('%Y-%m-%d %H:%M:%S')+'"', :order => "date_1 desc",:offset=> 1)
  @futures = DailydataDay.find(:all, :conditions =>'id_1 = 17060 and date_1 >= "'+Time.now.beginning_of_month().strftime('%Y-%m-%d %H:%M:%S')+'" and date_1 <= "'+Time.now.strftime('%Y-%m-%d %H:%M:%S')+'"', :order => "date_1 desc", :offset=> 1)
  @macro = DailydataDay.find(:all, :conditions =>'id_1 = 17063 and date_1 >= "'+Time.now.beginning_of_month().strftime('%Y-%m-%d %H:%M:%S')+'" and date_1 <= "'+Time.now.strftime('%Y-%m-%d %H:%M:%S')+'"', :order => "date_1 desc", :offset=> 1)
  @longShortCredit = DailydataDay.find(:all, :conditions =>'id_1 = 17055 and date_1 >= "'+Time.now.beginning_of_month().strftime('%Y-%m-%d %H:%M:%S')+'" and date_1 <= "'+Time.now.strftime('%Y-%m-%d %H:%M:%S')+'"', :order => "date_1 desc", :offset=> 1)
  @multiStrategy = DailydataDay.find(:all, :conditions =>'id_1 = 17064 and date_1 >= "'+Time.now.beginning_of_month().strftime('%Y-%m-%d %H:%M:%S')+'" and date_1 <= "'+Time.now.strftime('%Y-%m-%d %H:%M:%S')+'"',:order => "date_1 desc", :offset=> 1)
  
  i=1
  while((@globalIndex.empty? && @equity.empty? && @eventDrive.empty? && 
    @arbitrage.empty? && @longShortEquity.empty? && @futures.empty? && 
    @macro.empty? && @longShortCredit.empty? && @multiStrategy.empty? )|| 
    (@globalIndex.first.return.blank? && @equity.first.return.blank? && @eventDrive.first.return.blank? && 
    @arbitrage.first.return.blank? && @longShortEquity.first.return.blank? && @futures.first.return.blank? && 
    @macro.first.return.blank? && @longShortCredit.first.return.blank? && @multiStrategy.first.return.blank?))
    day = Time.now - i.days
    @globalIndex = DailydataDay.find(:all, :conditions =>'id_1 = 17056 and date_1 >= "'+day.beginning_of_month().strftime('%Y-%m-%d %H:%M:%S')+'" and date_1 <= "'+day.strftime('%Y-%m-%d %H:%M:%S')+'"', :order => "date_1 desc", :offset=> 1)
    @equity = DailydataDay.find(:all, :conditions =>'id_1 = 17058 and date_1 >= "'+day.beginning_of_month().strftime('%Y-%m-%d %H:%M:%S')+'" and date_1 <= "'+day.strftime('%Y-%m-%d %H:%M:%S')+'"', :order => "date_1 desc", :offset=> 1)
    @eventDrive = DailydataDay.find(:all, :conditions =>'id_1 = 17059 and date_1 >= "'+day.beginning_of_month().strftime('%Y-%m-%d %H:%M:%S')+'" and date_1 <= "'+day.strftime('%Y-%m-%d %H:%M:%S')+'"', :order => "date_1 desc", :offset=> 1)
    @arbitrage = DailydataDay.find(:all, :conditions =>'id_1 = 17057 and date_1 >= "'+day.beginning_of_month().strftime('%Y-%m-%d %H:%M:%S')+'" and date_1 <= "'+day.strftime('%Y-%m-%d %H:%M:%S')+'"', :order => "date_1 desc", :offset=> 1)
    @longShortEquity = DailydataDay.find(:all, :conditions =>'id_1 = 17062 and date_1 >= "'+day.beginning_of_month().strftime('%Y-%m-%d %H:%M:%S')+'" and date_1 <= "'+day.strftime('%Y-%m-%d %H:%M:%S')+'"', :order => "date_1 desc",:offset=> 1)
    @futures = DailydataDay.find(:all, :conditions =>'id_1 = 17060 and date_1 >= "'+day.beginning_of_month().strftime('%Y-%m-%d %H:%M:%S')+'" and date_1 <= "'+day.strftime('%Y-%m-%d %H:%M:%S')+'"', :order => "date_1 desc", :offset=> 1)
    @macro = DailydataDay.find(:all, :conditions =>'id_1 = 17063 and date_1 >= "'+day.beginning_of_month().strftime('%Y-%m-%d %H:%M:%S')+'" and date_1 <= "'+day.strftime('%Y-%m-%d %H:%M:%S')+'"', :order => "date_1 desc", :offset=> 1)
    @longShortCredit = DailydataDay.find(:all, :conditions =>'id_1 = 17055 and date_1 >= "'+day.beginning_of_month().strftime('%Y-%m-%d %H:%M:%S')+'" and date_1 <= "'+day.strftime('%Y-%m-%d %H:%M:%S')+'"', :order => "date_1 desc", :offset=> 1)
    @multiStrategy = DailydataDay.find(:all, :conditions =>'id_1 = 17064 and date_1 >= "'+day.beginning_of_month().strftime('%Y-%m-%d %H:%M:%S')+'" and date_1 <= "'+day.strftime('%Y-%m-%d %H:%M:%S')+'"',:order => "date_1 desc", :offset=> 1)
    i = i+1
  end
  
  
  @globalIndex.each do |t|
    @globalIndexMTD = !t.return.nil? && !t.return.blank? ? (@globalIndexMTD.nil? ? t.return.to_f + 1 : (@globalIndexMTD*(t.return.to_f+1))) : @globalIndexMTD
  end
  @globalIndexMTD = (@globalIndexMTD - 1)*100
  @globalIndexYTD = Time.now.month != 1 ? ((Information.find_by_id_1(17056).f_ytd+1)*(1+@globalIndexMTD))-1 : @globalIndexMTD
  
  @equity.each do |t|
    @equityMTD = !t.return.nil? && !t.return.blank? ? (@equityMTD.nil? ? t.return.to_f + 1 : (@equityMTD*(t.return.to_f+1))) : @equityMTD
  end
  @equityMTD = (@equityMTD - 1)*100
  @equityYTD = Time.now.month != 1 ? ((Information.find_by_id_1(17058).f_ytd+1)*(1+@equityMTD))-1 : @equityMTD
  
  @eventDrive.each do |t|
    @eventDriveMTD = !t.return.nil? && !t.return.blank? ? (@eventDriveMTD.nil? ? t.return.to_f + 1 : (@eventDriveMTD*(t.return.to_f+1))) : @eventDriveMTD 
  end
  @eventDriveMTD = (@eventDriveMTD - 1)*100
  @eventDriveYTD = Time.now.month != 1 ? ((Information.find_by_id_1(17059).f_ytd+1)*(1+@eventDriveMTD))-1 : @eventDriveMTD
  
  @arbitrage.each do |t|
    @arbitrageMTD  = !t.return.nil? && !t.return.blank? ? (@arbitrageMTD.nil? ? t.return.to_f + 1 : (@arbitrageMTD*(t.return.to_f+1))) : @arbitrageMTD   
  end
  @arbitrageMTD = (@arbitrageMTD - 1)*100
  @arbitrageYTD = Time.now.month != 1 ? ((Information.find_by_id_1(17057).f_ytd+1)*(1+@arbitrageMTD))-1 : @arbitrageMTD
  
  @longShortEquity.each do |t|
    @longShortEquityMTD = !t.return.nil? && !t.return.blank? ? (@longShortEquityMTD.nil? ? t.return.to_f + 1 : (@longShortEquityMTD*(t.return.to_f+1))) : @longShortEquityMTD  
  end
  @longShortEquityMTD = (@longShortEquityMTD - 1)*100
  @longShortEquityYTD = Time.now.month != 1 ? ((Information.find_by_id_1(17062).f_ytd+1)*(1+@longShortEquityMTD))-1 : @longShortEquityMTD
  
  @futures.each do |t|
    @futuresMTD = !t.return.nil? && !t.return.blank? ? (@futuresMTD.nil? ? t.return.to_f + 1 : (@futuresMTD*(t.return.to_f+1))) : @futuresMTD  
  end
  @futuresMTD = (@futuresMTD - 1)*100
  @futuresYTD = Time.now.month != 1 ? ((Information.find_by_id_1(17060).f_ytd+1)*(1+@futuresMTD))-1 : @futuresMTD
  
  @macro.each do |t|
    @macroMTD = !t.return.nil? && !t.return.blank? ? (@macroMTD.nil? ? t.return.to_f + 1 : (@macroMTD*(t.return.to_f+1))) : @macroMTD
  end
  @macroMTD = (@macroMTD - 1)*100
  @macroYTD = Time.now.month != 1 ? ((Information.find_by_id_1(17063).f_ytd+1)*(1+@macroMTD))-1 : @macroMTD
  
  @longShortCredit.each do |t|
    @longShortCreditMTD  = !t.return.nil? && !t.return.blank? ? (@longShortCreditMTD.nil? ? t.return.to_f + 1 : (@longShortCreditMTD*(t.return.to_f+1))) : @longShortCreditMTD  
  end
  @longShortCreditMTD = (@longShortCreditMTD - 1)*100
  @longShortCreditYTD = Time.now.month != 1 ? ((Information.find_by_id_1(17055).f_ytd+1)*(1+@longShortCreditMTD))-1 : @longShortCreditMTD
  
  @multiStrategy.each do |t|
    @multiStrategyMTD = !t.return.nil? && !t.return.blank? ? (@multiStrategyMTD.nil? ? t.return.to_f + 1 : (@multiStrategyMTD*(t.return.to_f+1))) : @multiStrategyMTD 
  end
  @multiStrategyMTD = (@multiStrategyMTD - 1)*100
  @multiStrategyYTD = Time.now.month != 1 ? ((Information.find_by_id_1(17064).f_ytd+1)*(1+@multiStrategyMTD))-1 : @multiStrategyMTD
  
  render :layout=>false
end

def etf
  #if !HfEtf.first.updated_at.today? 
  
  if HfEtf.count==0 or (Time.now - HfEtf.first.updated_at)>1000
  #if !HfEtf.first.updated_at.today?
    redirect_to :action=>"generate_etf"
  else
    render :layout=>"application_blank"
  end
end

def generate_etf
  HfEtf.destroy_all
=begin  
  arr = [{:fund_name=>"Greenwich Global Hedge Fund ETF", :tip=>10, :pos=>100},
  {:fund_name=>"Greenwich Long-Short Equity Hedge Fund ETF", :tip=>10, :pos=>200},
  {:fund_name=>"Greenwich Market Neutral Hedge Fund ETF", :tip=>10, :pos=>300},
  {:fund_name=>"Comparative Benchmarks", :tip=>20, :pos=>400},
  {:fund_name=>"S&P 500 TR", :tip=>10, :pos=>500},
  {:fund_name=>"MSCI WEI", :tip=>10, :pos=>600},
  {:fund_name=>"Nikkei 225", :tip=>10, :pos=>700}
  ]
=end
  arr = []
  Settings.etf_list.split("\n").each do |rn|
    prn = rn.split(",")
    arr << { :fund_name=>prn[0], :tip=>prn[1].to_i, :pos=>prn[2].to_i }
  end
  
  arr.each do |ar|
    fund_name = ar[:fund_name]
    pos = ar[:pos].to_i
    tip = ar[:tip].to_i
    
    hf_name = fund_name.gsub("Greenwich ", "").gsub(" Hedge Fund ETF","").gsub("Aggregate", "Agg")
    hf = HfEtf.new
    hf.name = hf_name
    
    if tip==10
      i=Information.find_by_f20(fund_name)
      hf.dtd = i.dtd*100
      hf.mtd = i.mtd*100
      hf.ytd = i.ytd2*100
      hf.itd = i.itd2*100
      hf.car = Information.car(i.itd_data+[hf.mtd/100])
      hf.std = Information.std(i.itd_data+[hf.mtd/100])
      hf.id_1 = i.id_1
      hf.dt = DailydataDay.first(:conditions=>["id_1= ? and `return`!=''", i.id_1], :order=>"date_1 desc").date_1
    end
    
    hf.pos = pos
    hf.tip = tip
    hf.save
  end
  
  redirect_to :action=>:etf
  
  
end

def indices
  render :layout=>false
end


def etf_admin

end

def preview_indices
  @tm = Time.at(params[:tm].to_i)
  @internal_id = params[:internal_id]
  @hf_indices = HfIndice.all(:conditions=>["mn = ? and yr = ? and internal_id=?", @tm.month, @tm.year, @internal_id], :order=>"position")
end

def publish_indices
  @tm = Time.at(params[:tm].to_i)
  @internal_id = params[:internal_id]
  redirect_to :action=>"preview_indices", :tm=>@tm.to_i, :internal_id=>@internal_id
end


def generate_indices
  #HfIndice.destroy_all
  @st = Time.now
  tm = Time.now-1.month
  pos = 0
  genlist = params[:internal_id] || "list1"
  ls = HfList.find_by_internal_id(genlist)
  wgs = {}
  hfis = HfIndiceReal.all(:conditions=>["internal_id = ?", genlist])
  hfis.each do |hfi|
    wgs[hfi.fund_name] = hfi.weight
  end
  
  
  hfis = HfIndice.all(:conditions=>["internal_id = ?", genlist])
  hfis.each do |hfi|
      hfi.destroy
  end
  
  
  pl = Performance.first(:order=>"date_1 desc", :conditions=>["`return`!='' and id_1 = ?", Information.find_by_f20(ls.indices.split("\n")[0].split("#")[1].gsub("$","").gsub("\r","")).id_1])
  if !pl.nil?
    tm = pl.date_1
  end
  
  
  ls.indices.split("\n").each do |ind|
    if !ind.strip.blank?
      pos = pos + 1
      ind = ind.strip
      pind = ind.split("#\$")
      nm = pind[1]
      prm = pind[0].split("\$")
      tp = prm[1]
      if tp=="FUND"
            if prm[2]=="32323"
              #Information.month_data(tm)
            elsif prm[2]=="3" or prm[2]=="2" or prm[2]=="1" or prm[2]=="0" or prm[2]=="5"
              i = Information.find_by_f20(nm)
              if !i.nil?
                hi = HfIndice.first(:conditions=>["f20 like ? and mn = ? and yr = ? and internal_id = ?", i.f20, tm.month, tm.year, ls.internal_id])
                if hi.nil?
                  hi = HfIndice.new
                  hi.f20 = i.f20
                  hi.fund_name = i.f20.gsub("Greenwich Global ","").gsub(" Index","").gsub("Hedge Fund", "Greenwich Global Hedge Fund Index")
                  hi.internal_id = ls.internal_id
                end
                hi.weight = wgs[hi.fund_name] if !wgs[hi.fund_name].nil?
                hi.mn = tm.month
                hi.yr = tm.year
                hi.position = pos*100
                hi.level = prm[2]
                hi.total_return = i.month_data(tm,0)
                hi.prev_return = i.month_data(tm-1.month,0)
                hi.ytd = Information.cummulative(i.ytd_data(tm))
                hi.mon3 = Information.cummulative(i.perf_data(tm,3))
                hi.yr1 = Information.cummulative(i.perf_data(tm,12))
                hi.ann_yr3_car = Information.car(i.perf_data(tm,36))
                hi.ann_yr3_std = Information.std(i.perf_data(tm,36))
                hi.ann_yr5_car = Information.car(i.perf_data(tm,60))
                hi.ann_yr5_std = Information.std(i.perf_data(tm,60))
                if !i.userinformation4.f15.nil?
                  begin
                  nm = ((tm.to_time - i.userinformation4.f15.to_time) / 86400 / 30).floor
                  rescue
                    logger.info "TST: "+i.id.to_s
                  end
                else
                  nm = 12
                end
                
                hi.ann_yr1_car = Information.car(i.perf_data(tm,nm))
                hi.ann_yr1_std = Information.std(i.perf_data(tm,nm))
                #hi.inception_date = i.f21.strftime("%d-%b-%Y") if !i.f21.nil?
                hi.inception_date = i.userinformation4.f15
                hi.tip="FUND"
                hi.save
              end
            end
      elsif tp=="DESC"
            hi = HfIndice.first(:conditions=>["f20 like ? and mn = ? and yr = ? and internal_id = ?", nm, tm.month, tm.year, ls.internal_id])
            if hi.nil?
              hi = HfIndice.new
              hi.fund_name = nm
              hi.internal_id = ls.internal_id
              hi.tip="DESC"
            end
            hi.mn = tm.month
            hi.yr = tm.year
            hi.level=prm[2]
            hi.position = pos*100
            hi.save
      elsif tp=="CLIST" or tp=="CLISTH"
        cl = HfList.find(:first, :conditions=>["internal_id = ?", prm[2]])
        if !cl.nil?
          i = Information.find_by_f20(cl.name)
          hi = HfIndice.first(:conditions=>["f20 like ? and mn = ? and yr = ? and internal_id = ?", cl.name, tm.month, tm.year, ls.internal_id])
          if hi.nil?
            hi = HfIndice.new
            hi.fund_name = cl.name.gsub("Greenwich Developed Markets ","").gsub("Greenwich Emerging Markets ","").gsub("Developed Markets", "Developed Markets Composite Index").gsub("Emerging Markets", "Emerging Markets Composite Index").gsub(" Regional Index","")
            hi.f20 = cl.name
            hi.internal_id = ls.internal_id
          end
          hi.mn = tm.month
          hi.yr = tm.year
          hi.position = pos*100
          if tp=="CLIST"
            hi.level = 5
          else 
            hi.level = 6
          end
          hi.total_return = i.month_data(tm,0)
          hi.prev_return = i.month_data(tm-1.month,0)
          hi.ytd = Information.cummulative(i.ytd_data(tm))
          hi.mon3 = Information.cummulative(i.perf_data(tm,3))
          hi.yr1 = Information.cummulative(i.perf_data(tm,12))
          #hi.ann_yr3_car = Information.car(i.perf_data(tm,36))
          #hi.ann_yr3_std = Information.std(i.perf_data(tm,36))
          #hi.ann_yr5_car = Information.car(i.perf_data(tm,60))
          #hi.ann_yr5_std = Information.std(i.perf_data(tm,60))
          
          hi.tip="CLIST"
          hi.save
        end
        
=begin        
        cl = HfList.find(:first, :conditions=>["internal_id = ?", prm[2]])
        csz = cl.cs.split(" ")
        a = []
        csz.each do |cs|
          a<<"uc7.c"+cs+"=1" if !cs.strip.blank?
        end
        abc = ActiveRecord::Base.connection
        q = "select i.id_1 from information i join usercheck7 uc7 on i.id_1=uc7.id_1 where "+a.join(" or ")
        rez = abc.execute(q)
        @aa = []
        while row=rez.fetch_hash
          @aa << row["id_1"].to_i
        end
        @aa = @aa.uniq
        hi=HfIndice.new
        hi.fund_name = cl.name
        hi.mn=tm.month
        hi.yr=tm.year
        hi.internal_id = ls.internal_id
        hi.tip="CLIST"
        hi.level = 5
        hi.position = pos*100
        start_date1 = (hi.yr.to_s+"-"+hi.mn.to_s+"-01 00:00:00").to_time
        end_date1 = (hi.yr.to_s+"-"+hi.mn.to_s+"-01 00:00:00").to_time.end_of_month
        data_this_mon = Performance.all(:conditions=>["date_1 between ? and ? and id_1 in (?) and `return` between -0.25 and 0.25", start_date1,end_date1, @aa]).map{|c| c.return}
        data_last_mon = Performance.all(:conditions=>["date_1 between ? and ? and id_1 in (?) and `return` between -0.25 and 0.25", start_date1-1.month,(end_date1-1.month).end_of_month, @aa]).map{|c| c.return}
        data_ytd = Performance.all(:conditions=>["date_1 between ? and ? and id_1 in (?) and `return` between -0.25 and 0.25", start_date1.year.to_s+"-01-01",end_date1, @aa]).map{|c| c.return}
        data_mon3 = Performance.all(:conditions=>["date_1 between ? and ? and id_1 in (?) and `return` between -0.25 and 0.25", (start_date1-3.month),end_date1, @aa]).map{|c| c.return}
        data_yr1 = Performance.all(:conditions=>["date_1 between ? and ? and id_1 in (?) and `return` between -0.25 and 0.25", (start_date1-12.month),end_date1, @aa]).map{|c| c.return}
        data_yr3 = Performance.all(:conditions=>["date_1 between ? and ? and id_1 in (?) and `return` between -0.25 and 0.25", (start_date1-36.month),end_date1, @aa]).map{|c| c.return}
        data_yr5 = Performance.all(:conditions=>["date_1 between ? and ? and id_1 in (?) and `return` between -0.25 and 0.25", (start_date1-60.month),end_date1, @aa]).map{|c| c.return}
        hi.total_return = Information.avg(data_this_mon)
        hi.prev_return = Information.avg(data_last_mon)
        hi.ytd = Information.cummulative(data_ytd)
        hi.mon3 = Information.cummulative(data_mon3)
        hi.yr1 = Information.cummulative(data_yr1)
        hi.ann_yr3_car = Information.car(data_yr3)
        hi.ann_yr5_car = Information.car(data_yr5)
        hi.ann_yr3_std = Information.std(data_yr3)
        hi.ann_yr5_std = Information.std(data_yr5)
        hi.save

          cl = HfList.find(:first, :conditions=>["internal_id = ?", prm[2]])
          csz = cl.cs.split(" ")
          a = []
          csz.each do |cs|
            a<<"uc7.c"+cs+"=1" if !cs.strip.blank?
          end
          abc = ActiveRecord::Base.connection
          q = "select i.id_1 from information i join usercheck7 uc7 on i.id_1=uc7.id_1 where "+a.join(" or ")
          rez = abc.execute(q)
          @aa = []
          while row=rez.fetch_hash
            @aa << row["id_1"].to_i
          end
          @aa = @aa.uniq
          Information.perf_data(@aa,tm,1)
=end          
      end
    end
    
  end
  @et = Time.now
  #render :layout=>false
  redirect_to :action=>genlist
  #redirect_to :action=>"preview_indices", :tm=>tm.to_i, :internal_id=>ls.internal_id
end


def list_ph1
  
end

def gen_ph1
  
end

def publish_ph1
  dt = params[:dt]
  yr = dt.split("_")[0][0..3]
  mn = dt.split("_")[0][4..5]
  f = File.open("hist_data/results_"+dt+".csv","r")
  k = ""
  while z=f.gets do
    pz = z.split(",")
    if pz.size==2
      i = Information.find_by_f20(pz[0])
      if !i.nil?
        p = Performance.first(:conditions=>["id_1 = ? and date_1 between ? and ?", i.id_1, yr+"-"+mn+"-01", yr+"-"+mn+"-31 00:00:00"])
        if p.nil?
          p = Performance.new
          p.id_1 = i.id_1
          p.date_1 = (yr+"-"+mn+"-01").to_date.end_of_month.strftime("%Y-%m-%d 00:00:00")
        end
        p.lastupdated = Time.now
        p.return = pz[1].to_f/100
        p.save
      end
    end
    k = k + z
  end
    
  f.close
  render :text=>"<script>alert('Data has been published'); document.location.href='/gai/list_ph1';</script>"
end

def hist_ph1
  dt = params[:dt]
  send_file("hist_data/historical_"+dt+".xls")
end

def results_ph1
  dt = params[:dt]
  send_file("hist_data/results_"+dt+".csv")
end

def delete_ph1
  dt = params[:dt]
  File.delete("hist_data/historical_"+dt+".xls")
  File.delete("hist_data/results_"+dt+".csv")
  redirect_to :action=>"list_ph1"
end

def weights_ph2_save
  params[:hfi].each do |i,hi|
      hfi = HfIndiceReal.find(i)
      hfi.weight = hi
      hfi.save
    end
    redirect_to :action=>"weights_ph2"
end

  def publish_list1
    ActiveRecord::Base.connection.execute("DROP TABLE greenwich_www_prod.jos_hf_indices2")
    ActiveRecord::Base.connection.execute("CREATE TABLE greenwich_www_prod.jos_hf_indices2 SELECT * FROM greenwich_www_prod.jos_hf_indices_staging")
    ActiveRecord::Base.connection.execute("alter TABLE greenwich_www_prod.jos_hf_indices2 MODIFY COLUMN id INT NOT NULL AUTO_INCREMENT key;")
    render :text=>"<script>alert('Data has been published'); document.location.href='/admin';</script>"
  end
end
