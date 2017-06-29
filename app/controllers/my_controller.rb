class MyController < ApplicationController
	before_filter :login_required
	after_filter :do_log
	
	def do_log
		#LogEvent.new(:c=>request.parameters['controller'],:m=>request.parameters['action'], :p=>request.parameters.to_param, :user_id=>(current_user.nil? ? nil : current_user.id)).save
	end

  def landing
    if current_user.tip=="member"
      redirect_to update_my_funds_path
    end
  end

  def my_peer_portfolio   
    @portfolio_funds = current_user.peer_portfolios
    render :layout => 'search'
  end

  def my_performance_summary
    if current_user.tip=="admin"
      @informations = current_user.funds  
    else
      get_informations  
    end
  end  

  def my_funds
    @informations = []
    ManagerToFund.find(:all, :conditions=>["MANAGER_ID = ?", current_user.manager_id]).each do |mtf|
      Information.find(:all, :conditions=>["ID_1 = ? and upper(F20) not like ? and upper(F20) not like ? and upper(F20) not like ? and upper(F20) not like ? ", mtf.fund_id, "%DELETE%", "%WRI%","%DUPLICATE%","%DEFUNCT%"]).each do |information|
        @informations << information 
      end 
    end 

    @informations = @informations.group_by {|item| item.send('f15')}
    @order_by = params[:order_by] || 'desc'
    @sort_by  = params[:sort_by]

    @risk_dashboard_snapshot = Information.risk_dashboard_snapshot(@informations, {:sort_by => params[:sort_by], :order => @order_by})           
    if request.xhr?
      return render :layout => false
    end

    respond_to do |format|
      format.html do
       @format = "html"
       render :template => 'my/my_funds.html',
              :layout  => 'portfolio'
      end
      format.pdf do
        @format = "pdf"
        render  :pdf => 'my_funds_summary',
                :template => 'my/my_funds.html',
                :layout  => 'portfolio', :orientation => 'landscape' 
      end

      format.csv do
        @format       = "csv"
        @report_type  = "my_funds"
        csv_data      = Information.export_to_excel(@risk_dashboard_snapshot)
        csv_data ||= "Sorry! no data found. Try again."

        File.open(@report_type+'.csv', 'w') do |f|
          f.write(csv_data)
        end

        send_data csv_data, 
                :type => 'text/csv; charset=iso-8859-1; header=present', 
                :disposition => "attachment; filename=#{@report_type}_#{Time.now.to_i}.csv"         
      end      
    end  
  end    
		
	def index
	  if(flash[:alert] == "A new password has been emailed to you. If you do not see it in your inbox shortly, please be sure to check spam folders. For further assistance, please contact us at +1.203.487.6180 on info@greenwichai.com")
      		current_user_session.destroy
      		redirect_to "/"
    	end		
    if current_user.accessed_at.nil? or (Time.now - current_user.accessed_at)>1.minute
      current_user.accessed_at = Time.now
      current_user.save 
    end
    
    get_informations
	end
	
	def perfs
		@current_menu = "perfs"
		date_fmt = "%Y-%m%-%d"
		date_tpl = "?"
		
		@limit_items = params[:limit]||50
		
		@span_period = params[:span_period] || "month"
		@fund_information = Information.find(params[:id])
    @user1 = @fund_information.userinformation1
		@system1 = Systeminformation1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		if @system1.nil?
			@system1 = Systeminformation1.new
			@system1.id_1 = @fund_information.id_1
      @system1.datavendorname="VAN"
      @system1.datavendorid=@fund_information.datavendorid
			@system1.save
		end
		@inception_date = @fund_information.f21 ? @fund_information.f21.to_time : "1990-01-01".to_time
		#@inception_date = @fund_information.f21.to_time
		@systemcontrol = @fund_information.systemcontrol
		
		if !params[:ds].nil?
			@date2 = params[:ds]["from_date(1i)"]+"-"+params[:ds]["from_date(2i)"]+"-"+params[:ds]["from_date(3i)"]
			@date2 = @date2.to_time
			@date2 = Time.now if @date2>Time.now
		else
			@date2 = Time.now
		end
		@date1 = @date2
		@date1 = @date1 - (@limit_items).to_i.months if (@span_period=="month")
		@date1 = @date1 - (@limit_items).to_i.weeks if (@span_period=="week")
		@date1 = @date1 - (@limit_items).to_i.days if (@span_period=="day")
		@date1 = @inception_date if @date1<@inception_date 
		
		@dts=[]
		b=@date1
		a=@date2
		
		
		if @span_period=="week"
			first_friday = a-(2+a.wday).days if a.wday<5
			first_friday = a-(a.wday-5).days if a.wday>4
			first_friday = a-2.days if a.wday==0
			first_friday = first_friday + 1.week
			next_friday = first_friday
			@dts << next_friday if next_friday>@inception_date
			while (next_friday = next_friday - 7.days) > b-1.second do
				@dts << next_friday
			end
		end
		
		if @span_period=="month"
			eom = a.end_of_month
			#@dts << eom if eom>@inception_date
			while ( (eom = (eom - 1.month).end_of_month) > b) do 
				@dts << eom
			end
		end
		
		if @span_period=="day"
			first_day = a
			@dts << first_day if first_day>@inception_date
			while ( first_day = first_day - 1.day ) > b-1.second do
				@dts << first_day 
			end
		end
		if @dts.size==0
			@dts << (Time.now - 1.month).end_of_month
		end
		if @span_period=="month"
			elements = Performance.find(:all, 
						:conditions=>["ID_1 = ? and DATE_1 between ? and ?",
						@fund_information.id_1, @dts.last-1.day, @dts.first], 
						:order=>"DATE_1 desc")
		end
		if @span_period=="week"
			elements = Dailydata.find(:all, 
						:conditions=>["ID_1 = ? and DATE_1 between ? and ?",
						@fund_information.id_1, @dts.last, @dts.first], 
						:order=>"DATE_1 desc")
		end
		if @span_period=="day"
			elements = DailydataDay.find(:all, 
						:conditions=>["ID_1 = ? and DATE_1 between ? and ?",
						@fund_information.id_1, @dts.last, @dts.first], 
						:order=>"DATE_1 desc")
		end
		
		elements_v2 = {}
		elements.each do |element|
			elements_v2[element.date_1.strftime("%Y-%m-%d").gsub("-","")] = element
		end
		@datefmt = @dts.last.strftime("%Y")
		@perf_vals = elements_v2
		@elements = elements
	end
	
	def perfs_save
		cls=Performance
		cls=Dailydata if params[:span_period]=="week"
		cls=DailydataDay if params[:span_period]=="day"
		@fund = Information.find(params[:id])
		@other_funds = @fund.other_funds_in_firm
    @user1 = @fund.userinformation1
    @user1.update_attributes(params[:userinformation1])
		params[:d_return].each do |indice,vl|
			indice = indice
			d_indice = indice[0..3]+"-"+indice[4..5]+"-"+indice[6..7]
			#d_indice = indice
			d_return = params[:d_return][indice].blank? ? "" : params[:d_return][indice].to_f/100
			d_fundaum = number_to_currency(params[:d_fundaum][indice].to_f*1000000, :precision=>0).gsub("$","")
			d_firmaum = number_to_currency(params[:d_firmaum][indice].to_f*1000000, :precision=>0).to_s.gsub("$","")
			d_gross_exposure = params[:d_gross_exposure][indice]
      fund_aum_blank = params[:d_fundaum][indice].to_s.strip == ""
      
      if current_user.tip=="admin"
        d_aum_ds = params[:d_aum_ds][indice] 
        d_return_ds = params[:d_return_ds][indice]
      elsif current_user.tip=="data_entry2"
        d_aum_ds = "Data Entry 2"
        d_return_ds = "Data Entry 2"
      elsif current_user.tip=="data_entry"
        d_aum_ds = "Data Entry"
        d_return_ds = "Data Entry"
      else
        d_aum_ds = "Self-Reporting"
        d_return_ds = "Self-Reporting"
      end
      
			d_nav_shares = params[:d_nav_shares][indice]
			d_estimate = params[:d_estimate][indice]=="no" ? 0 : 1
			
			obj = cls.find(:first, :conditions=>["id_1=? and date_1=?",params[:fund_id],d_indice.to_time.strftime("%Y-%m-%d")+" 00:00:00"])
			if obj.nil?
				obj = cls.new
				obj.id_1 = params[:fund_id]
				obj.date_1 = indice.to_time.strftime("%Y-%m-%d")+" 00:00:00"
			end
      
      
      if obj.return!=d_return and obj.return.to_f==0 and d_return.to_s.strip!=""
        obj.return_ds = d_return_ds
        obj.return_ut = Time.now
      end
      #if obj.fundsmanaged!=d_fundaum and obj.fundsmanaged.to_f==0 and d_fundaum!='' and d_aum_ds!=''
      #if (obj.fundsmanaged.to_f != d_fundaum.to_f and d_aum_ds!='' and d_aum_ds!='0' and d_aum_ds!=nil) or (d_aum_ds!='' and d_aum_ds!='0' and d_aum_ds!=nil and obj.aum_ds != d_aum_ds)
      if obj.fundsmanaged!=d_fundaum and obj.fundsmanaged.to_f==0 and d_fundaum.to_s.strip!='' and !fund_aum_blank
        obj.aum_ds = d_aum_ds
        obj.aum_ut = Time.now
        
      end
      #end
      
=begin			
      if current_user.tip == "admin"
          if (obj.return.to_s.strip=="" or obj.return_ds.to_s.strip=="") and (d_return_ds.to_f!=0 and obj.return_ds.to_f==0)
            obj.return_ds = d_return_ds
            obj.return_ut = Time.now
          end
          if (obj.aum_ds.to_s.strip=="" or obj.aum_ds.to_s.strip=="") and (d_aum_ds.to_f!=0 and obj.fundsmanaged.to_f==0)
            obj.aum_ds = d_aum_ds
            obj.aum_ut = Time.now
          end
      else
          if obj.return.to_s.strip=="" or obj.return_ds.to_s.strip==""
            obj.return_ds = "Self-Reporting"
            obj.return_ut = Time.now
          end
          if obj.aum_ds.to_s.strip=="" or obj.aum_ds.to_s.strip==""
            obj.aum_ds = "Self-Reporting"
            obj.aum_ut = Time.now
          end
      end
=end
      
			obj.return = d_return
			obj.fundsmanaged = d_fundaum.to_f == 0 ? nil : d_fundaum
			obj.nav = d_nav_shares
			obj.estimate = d_estimate
			obj.gross_exposure = d_gross_exposure
			
      @fund_information = Information.find(params[:id])
			@system1 = @fund_information.systeminformation1
			fl_firmaum = 0

      d_firmaum = "" if params[:d_firmaum][indice].to_s.strip==''
      if obj.firm_aum!=d_firmaum
          fl_firmaum = 1 
          @system1.f37 = Time.now.strftime("%m/%d/%Y %H:%M:%S")
          @system1.save
          
          @fund_information.other_funds_in_firm.each do |i2|
            si1 = i2.systeminformation1
            si1.f37 = Time.now.strftime("%m/%d/%Y %H:%M:%S")
            si1.save
          end
      end

			obj.firm_aum = d_firmaum
			obj.save
			
			if fl_firmaum==1
				@other_funds.each do |f|
					obj = cls.find(:first, :conditions=>["id_1=? and date_1=?",f.id_1,indice.to_time])
			
					if obj.nil?
						obj = cls.new
						obj.id_1 = f.id_1
						obj.date_1 = indice.to_time.strftime("%Y-%m-%d")+" 00:00:00"
					end
					#if obj.firm_aum.to_s != d_firmaum
					#	@system1.f37 = Time.now.strftime("%m/%d/%Y %H:%M:%S")
					#	@system1.save
					#end
					obj.firm_aum = d_firmaum
					obj.save
			
        end
        
			end
			
		end
		@fund_information = Information.find(params[:id])
		@fund_information.lastupdated = Time.now.strftime("%Y-%m-%d %H:%M:%S")
		
		
		
		@systemcontrol = @fund_information.systemcontrol
		@systemcontrol.nav = params[:systemcontrol][:nav]
		@systemcontrol.save 
		@system1 = Systeminformation1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@system1.f27 = number_to_currency(params[:systeminformation1][:f27].to_f*1000000, :precision=>0).gsub("$","")
    @system1.f27 = nil if @system1.f27.nil? || @system1.f27.to_f.to_s == ("0.0")
		@system1.f31 = (params[:systeminformation1][:f31].gsub(",","").to_f>0) ? number_to_currency(params[:systeminformation1][:f31].gsub(",","").to_f*1000000, :precision=>0).gsub("$","") : params[:systeminformation1][:f31]
		#@system1.f35 = (params[:systeminformation1][:f35].gsub(",","").to_f>0) ? number_to_currency(params[:systeminformation1][:f35].gsub(",","").to_f*1000000, :precision=>0).gsub("$","") : params[:systeminformation1][:f35]
		
		@system1.f28 = params[:systeminformation1][:f28]
		@system1.f32 = params[:systeminformation1][:f32]
		@system1.f36 = params[:systeminformation1][:f36]
		
		@fund_information.f35 = params[:information][:f35]
		@system1.f28 = params[:over_systeminformation1][:f28].upcase.gsub(/^EURO$/i,"EUR") if !params[:over_systeminformation1][:f28].strip.blank? && params[:systeminformation1][:f28].eql?("other")
		@system1.f32 = params[:over_systeminformation1][:f32].upcase.gsub(/^EURO$/i,"EUR") if !params[:over_systeminformation1][:f32].strip.blank?  && params[:systeminformation1][:f32].eql?("other")
		@system1.f36 = params[:over_systeminformation1][:f36].upcase.gsub(/^EURO$/i,"EUR") if !params[:over_systeminformation1][:f36].strip.blank?  && params[:systeminformation1][:f36].eql?("other")
		@fund_information.f35 = params[:over_information][:f35].upcase.gsub(/^EURO$/i,"EUR") if !params[:over_information][:f35].strip.blank? && params[:information][:f35].eql?("other")
		
		
		
		
		if @system1.f36.to_s != params[:old_si1_f36].to_s
			#@system1.f37 = Time.now.strftime("%m/%d/%Y %H:%M:%S")
      @fund_information.other_funds_in_firm.each do |i2|
        si1 = i2.systeminformation1
        #si1.f37 = Time.now.strftime("%m/%d/%Y %H:%M:%S")
        si1.save
      end
		end
		
		if @system1.f32.to_s != params[:old_si1_f32].to_s
			@system1.f33 = Time.now.strftime("%m/%d/%Y %H:%M:%S")
		end
		
		if @system1.f31.to_s != params[:old_si1_f31].to_s
			@system1.f33 = Time.now.strftime("%m/%d/%Y %H:%M:%S")
		end
		
		
		@system1.save
		@system1.reload
		@fund_information.f33 = @fund_information.last_aum
    @fund_information.f34 = @fund_information.last_firm_aum

		@fund_information.save
		
		mtf = ManagerToFund.find(:first, :conditions=>["fund_id = ?", @fund_information.id_1])
		if !mtf.nil?
			ManagerToFund.find(:all, :conditions=>["manager_id = ?", mtf.manager_id]).each do |mt|
				s1 = Systeminformation1.find(:first, :conditions=>["id_1=?", mt.fund_id])
				if !s1.nil?
					s1.f35 = @system1.f35
          s1.f35 = nil if s1.f35.nil? || s1.f35.to_f.to_s == "0.0"
					s1.save
				end
			end
		end
		
		@other_funds.each do |f|
			si1 = Systeminformation1.find(:first, :conditions=>["id_1 = ?", f.id_1])
			si1.f36 = @system1.f36
			si1.save
		end
		
		flash[:sv] = 1
		redirect_to(:action=>"perfs", :id=>params[:id], :span_period=>params[:span_period])
	end
	
	def firm_info
		@current_menu = "firm_info"
		@fund_information = Information.find(params[:id])
		@manager_id = ManagerToFund.find(:first, :conditions=>["FUND_ID = ?",@fund_information.id_1]).manager_id
		@manager_information = ManagerInformation.find(:first, :conditions=>["MANAGER_ID = ?", @manager_id])
		@system1 = Systeminformation1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
	end
	
	def firm_info_save
		@fund_information = Information.find(params[:id])
		@system1 = Systeminformation1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		params[:information][:f2] = params[:information][:f2].to_xs
		@fund_information.update_attributes(params[:information])
		
		@usercheck2 = @fund_information.usercheck2
		if params[:usercheck2].nil?
			@usercheck2.c60 = 0
		else 
			@usercheck2.c60 = params[:usercheck2][:c60].to_i
		end
		@usercheck2.save
		
		@system1.update_attributes(params[:systeminformation1])
		@manager_id = ManagerToFund.find(:first, :conditions=>["FUND_ID = ?",@fund_information.id_1]).manager_id
		@manager_information = ManagerInformation.find(:first, :conditions=>["MANAGER_ID = ?", @manager_id])
		@manager_information.update_attributes(params[:manager_information])
    @manager_information.email = @fund_information.f11
		@manager_information.amf = params[:manager_information][:amf]
		
		@manager_information.asic = params[:manager_information][:asic]
		@manager_information.broker_dealer = params[:manager_information][:broker_dealer]
		@manager_information.fsc_bvi = params[:manager_information][:fsc_bvi]
		@manager_information.cima = params[:manager_information][:cima]
		@manager_information.cob = params[:manager_information][:cob]
		@manager_information.cpo = params[:manager_information][:cpo]
		@manager_information.cta = params[:manager_information][:cta]
		@manager_information.sfa = params[:manager_information][:sfa]
		@manager_information.fsc_isle = params[:manager_information][:fsc_isle]
		
		@manager_information.gfsc = params[:manager_information][:gfsc]
		@manager_information.ifsra = params[:manager_information][:ifsra]
		@manager_information.imro = params[:manager_information][:imro]
		@manager_information.nasd = params[:manager_information][:nasd]
		@manager_information.nfa = params[:manager_information][:nfa]
		@manager_information.osc = params[:manager_information][:osc]
		@manager_information.other = params[:manager_information][:other]
		@manager_information.registered_investment_advisor = params[:manager_information][:registered_investment_advisor]
		@manager_information.sfc = params[:manager_information][:sfc]
    @manager_information.address1 = @fund_information.f2
    @manager_information.address2 = @fund_information.f3
    @manager_information.city = @fund_information.f4
    @manager_information.state_province = @fund_information.f5
    @manager_information.zip = @fund_information.f6
    @manager_information.country = @fund_information.f7
    
    
    
    
    @manager_information.phone = @fund_information.f9
    @manager_information.fax = @fund_information.f10
    @manager_information.email = @fund_information.f11
    @manager_information.contact_person = @fund_information.f12
    @manager_information.contact_title = @fund_information.f13
    
    @manager_information.website = @fund_information.f18
    @manager_information.firm_assets = @fund_information.f34
    @manager_information.currency_of_firm_assets  = @fund_information.f35
    
		@manager_information.save 
		@fund_information.f1 = @manager_information.general_partner
    @fund_information.save
    si_orig = params[:systeminformation1]
    si1 = si_orig
    si2 = {:f1=>si_orig[:f1],:f2=>si_orig[:f2],:f3=>si_orig[:f3],:f4=>si_orig[:f4],:f5=>si_orig[:f5],:f6=>si_orig[:f6],:f7=>si_orig[:f7],:f8=>si_orig[:f8],:f9=>si_orig[:f9],:f10=>si_orig[:f10]}
    si1.delete(:f1)
    si1.delete(:f2)
    si1.delete(:f3)
    si1.delete(:f4)
    si1.delete(:f5)
    si1.delete(:f6)
    si1.delete(:f7)
    si1.delete(:f8)
    si1.delete(:f9)
    si1.delete(:f10)
    
    @other_funds = @fund_information.other_funds_in_firm
    @other_funds.each do |of|
      of.update_attributes(params[:information])
      of.f1 = @manager_information.general_partner
      of.systeminformation1.update_attributes(si1)
    end
        
    
		if @fund_information.usercheck2.c60.to_i!=-1
			
			@other_funds.each do |of|
					if (of.usercheck2.c60.to_i!=-1)
            #of.f1 = @manager_information.general_partner
						#of.update_attributes(params[:information])
						#of.systeminformation1.update_attributes(params[:systeminformation1])
            of.systeminformation1.update_attributes(si2)
					end
			end
		end		
		
		flash[:sv] = 1
		redirect_to(:action=>"firm_info", :id=>params[:id])
	end
	
	
	
	def fund_info
		@current_menu = "fund_info"
		@fund_information = Information.find(params[:id])
		@user2 = @fund_information.userinformation2
		@sc5 = @fund_information.systemcheck5
		@manager_id = ManagerToFund.find(:first, :conditions=>["FUND_ID = ?",@fund_information.id_1]).manager_id
		@manager_information = ManagerInformation.find(:first, :conditions=>["MANAGER_ID = ?", @manager_id])
		@system1 = @fund_information.systeminformation1
		@user1 = @fund_information.userinformation1
		@user1.us_visible = "" if @user1.us_visible.nil?
		
	end
	
	def fund_info_save
		@fund_information = Information.find(params[:id])
    old_f20 = @fund_information.f20
		@user2 = @fund_information.userinformation2
		@user1 = @fund_information.userinformation1
		@sc5 = @fund_information.systemcheck5
		@system1 = @fund_information.systeminformation1
    
		@fund_information.update_attributes(params[:information])
		@system1.update_attributes(params[:systeminformation1])
		@user2.update_attributes(params[:userinformation2])
		@sc5.update_attributes(params[:systemcheck5])
		@manager_id = ManagerToFund.find(:first, :conditions=>["FUND_ID = ?",@fund_information.id_1]).manager_id
		@manager_information = ManagerInformation.find(:first, :conditions=>["MANAGER_ID = ?", @manager_id])
		@manager_information.update_attributes(params[:manager_information])
		
		@fund_information.f14 = params[:over_information][:f14] if !params[:over_information][:f14].strip.blank?
		@fund_information.f22 = params[:over_information][:f22].to_f/100 if !params[:over_information][:f22].strip.blank?
		@fund_information.f23 = params[:over_information][:f23] if !params[:over_information][:f23].strip.blank?
		@fund_information.f24 = params[:over_information][:f24].to_f/100 if !params[:over_information][:f24].strip.blank?
		@fund_information.f25 = params[:over_information][:f25] if !params[:over_information][:f25].strip.blank?
		@fund_information.f27 = params[:over_information][:f27] if !params[:over_information][:f27].strip.blank?
		@fund_information.f28 = params[:over_information][:f28] if !params[:over_information][:f28].strip.blank?
		@fund_information.f29 = params[:over_information][:f29] if !params[:over_information][:f29].strip.blank?
		@fund_information.f30 = params[:over_information][:f30] if !params[:over_information][:f30].strip.blank?
		@fund_information.f36 = params[:over_information][:f36] if !params[:over_information][:f36].to_s.strip.blank?
		@fund_information.f31 = params[:over_information][:f31] if !params[:over_information][:f31].strip.blank?
		@fund_information.f32 = params[:over_information][:f32] if !params[:over_information][:f32].strip.blank?
		@fund_information.f35 = params[:over_information][:f35] if !params[:over_information][:f35].strip.blank?
		@fund_information.save
    if @fund_information.f20!=old_f20
      m = Mastername.find_by_id_1(@fund_information.id_1)
      if m.nil?
        m = Mastername.new
        m.id_1 = @fund_information.id_1
      end
      
      m.mastername = @fund_information.f20
      m.save
    end
    
		@system1.f49 = params[:over_systeminformation1][:f49].upcase.gsub(/^EURO$/i,"EUR") if !params[:over_systeminformation1][:f49].strip.blank?
		@system1.save
    @user2.f9 = params[:over_userinformation2][:f9] if !params[:over_userinformation2][:f9].strip.blank?
    @user2.save
    @user1.us_visible = params[:user1][:us_visible]
    @user1.save
		flash[:sv] = 1
		redirect_to(:action=>"fund_info", :id=>params[:id])
	end
	
	def fund_strategy
		@current_menu = "fund_strategy"
		@fund_information = Information.find(params[:id])
		@manager_id = ManagerToFund.find(:first, :conditions=>["FUND_ID = ?",@fund_information.id_1]).manager_id
		@manager_information = ManagerInformation.find(:first, :conditions=>["MANAGER_ID = ?", @manager_id])
		@system1 = Systeminformation1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		
		@st_gr = [["Other",0]]+ElemOfSet.find(:all, :include=>"set_of_set", :conditions=>["set_of_sets.name=?", "strategy_group"]).map {|c| c.name }
	end
	
	def fs_sel1
		@fund_information = Information.find(params[:id])
		@st_pr = [["Other",0]]+ElemOfSet.find(:all, :include=>"set_of_set", :conditions=>["set_of_sets.name=?", params[:st_gr]]).map {|c| c.name }
		render :layout=>false
	end	
	def fs_sel2
		@fund_information = Information.find(params[:id])
		@st_se = [["Other",0]]+ElemOfSet.find(:all, :include=>"set_of_set", :conditions=>["set_of_sets.name=?", params[:st_pr]]).map {|c| c.name }
		render :layout=>false
	end	
	
	def fund_strategy_save
		@fund_information = Information.find(params[:id])
		@system1 = Systeminformation1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@fund_information.update_attributes(params[:information])
		@fund_information.f15 = params[:over_information][:f15] if !params[:over_information][:f15].strip.blank?
		@fund_information.f37 = params[:over_information][:f37] if !params[:over_information][:f37].strip.blank?
		@fund_information.f39 = params[:over_information][:f39] if !params[:over_information][:f39].strip.blank?
		update_peers(@fund_information)
		@fund_information.f40 = params[:over_information][:f40] if !params[:over_information][:f40].strip.blank?
		@fund_information.f38 = params[:over_information][:f38] if !params[:over_information][:f38].strip.blank?
		@fund_information.f41 = params[:over_information][:f41] if !params[:over_information][:f41].strip.blank?
		@fund_information.save
		@system1.update_attributes(params[:systeminformation1])
		@manager_id = ManagerToFund.find(:first, :conditions=>["FUND_ID = ?",@fund_information.id_1]).manager_id
		@manager_information = ManagerInformation.find(:first, :conditions=>["MANAGER_ID = ?", @manager_id])
		@manager_information.update_attributes(params[:manager_information])
		
		
		(1..36).each do |k|
			@fund_information.write_attribute("c"+k.to_s, params[:information]["c"+k.to_s])
		end
		@fund_information.save
		flash[:sv] = 1
		redirect_to(:action=>"fund_strategy", :id=>params[:id])
	end
	
	def update_peers(fund_information)
	  case fund_information.f39
    when 'Value'
      fund_information.peerGroup = "Long-Short Equity - Value"
      fund_information.peerBenchmark = "Greenwich Global Value Index"
    when 'Growth'
      fund_information.peerGroup = "Long-Short Equity - Growth"
      fund_information.peerBenchmark = "Greenwich Global Growth Index"
    when 'Opportunistic'
      fund_information.peerGroup = "Long-Short Equity - Opportunistic"
      fund_information.peerBenchmark = "Greenwich Global Opportunistic Index"
    when 'Short-Blased'
      fund_information.peerGroup = "Short-Biased"
      fund_information.peerBenchmark = "Greenwich Global Short-Biased Index"
    when 'Convertible Arbitrage'
      fund_information.peerGroup = "Convertible Arbitrage"
      fund_information.peerBenchmark = "Greenwich Global Convertible Arbitrage Index"
    when 'Fixed Income Arbitrage'
      fund_information.peerGroup = "Fixed Income Arbitrage"
      fund_information.peerBenchmark = "Greenwich Global Fixed Income Arbitrage Index"
    when 'Other Arbitrage'
      fund_information.peerGroup = "Other Arbitrage"
      fund_information.peerBenchmark = "Greenwich Global Other Arbitrage Index"
    when 'Several Arb Strategies'
      fund_information.peerGroup = "Other Arbitrage"
      fund_information.peerBenchmark = "Greenwich Global Other Arbitrage Index"
    when 'Distressed Securities'
      fund_information.peerGroup = "Distressed Securities"
      fund_information.peerBenchmark = "Greenwich Global Distressed Securities Index"
    when 'Diversified Event-Driven'
      fund_information.peerGroup = "Diversified Event-Driven"
      fund_information.peerBenchmark = "Greenwich Global Diversified Event-Driven Index"
    when 'Equity Market Neutral'
      fund_information.peerGroup = "Equity Market Neutral"
      fund_information.peerBenchmark = "Greenwich Global Neutral Index"
    when 'Futures'
      fund_information.peerGroup = "Futures"
      fund_information.peerBenchmark = "Greenwich Global Futures Index"
    when 'Long-Short Credit'
      fund_information.peerGroup = "Long-Short Credit"
      fund_information.peerBenchmark = "Greenwich Global Long-Short Credit Index"
    when 'Macro'
      fund_information.peerGroup = "Macro"
      fund_information.peerBenchmark = "Greenwich Global Macro Index"
    when 'Multi-Strategy'   
      fund_information.peerGroup = "Multi-Strategy"
      fund_information.peerBenchmark = "Greenwich Global Multi-Strategy Index"
    end
	end
	
	def profile1
		@current_menu = "profile1"
		@fund_information = Information.find(params[:id])
		@manager_id = ManagerToFund.find(:first, :conditions=>["FUND_ID = ?",@fund_information.id_1]).manager_id
		@manager_information = ManagerInformation.find(:first, :conditions=>["MANAGER_ID = ?", @manager_id])
		@system1 = Systeminformation1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@system5 = Systeminformation5.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		if @system5.nil?
			@system5 = Systeminformation5.new
			@system5.id_1=@fund_information.id_1
			@system5.save
		end
	end
	
	def profile1_save
		@fund_information = Information.find(params[:id])
		@system1 = Systeminformation1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@system5 = Systeminformation5.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@fund_information.update_attributes(params[:information])
		@system1.update_attributes(params[:systeminformation1])
		@system5.update_attributes(params[:systeminformation5])
		@manager_id = ManagerToFund.find(:first, :conditions=>["FUND_ID = ?",@fund_information.id_1]).manager_id
		@manager_information = ManagerInformation.find(:first, :conditions=>["MANAGER_ID = ?", @manager_id])
		@manager_information.update_attributes(params[:manager_information])
		flash[:sv] = 1
		redirect_to(:action=>"profile1", :id=>params[:id])
	end
	
	def profile2
		@current_menu = "profile2"
		@fund_information = Information.find(params[:id])
		@manager_id = ManagerToFund.find(:first, :conditions=>["FUND_ID = ?",@fund_information.id_1]).manager_id
		@manager_information = ManagerInformation.find(:first, :conditions=>["MANAGER_ID = ?", @manager_id])
		@system1 = Systeminformation1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@system5 = Systeminformation5.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		if @system5.nil?
			@system5 = Systeminformation5.new
			@system5.id_1=@fund_information.id_1
			@system5.save
		end
		@sc1 = Systemcheck1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@sc5 = Systemcheck5.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		
	end
	
	def profile2_save
		@fund_information = Information.find(params[:id])
		@system1 = Systeminformation1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@system5 = Systeminformation5.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@sc1 = Systemcheck1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@sc5 = Systemcheck5.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		
		@fund_information.update_attributes(params[:information])
		@system1.update_attributes(params[:systeminformation1])
		@system5.update_attributes(params[:systeminformation5])
		@manager_id = ManagerToFund.find(:first, :conditions=>["FUND_ID = ?",@fund_information.id_1]).manager_id
		@manager_information = ManagerInformation.find(:first, :conditions=>["MANAGER_ID = ?", @manager_id])
		@manager_information.update_attributes(params[:manager_information])
		#@sc1.update_attributes(params[:systemcheck1])
		#@sc5.update_attributes(params[:systemcheck5])
		sc5_arr = [32,33,34,36,38,40,44,46,47,48,50,51,52,54,55,57,59,2,4,6,8,10,12,14,16,18,20,24,26,28]
		sc5_arr.each do |k|
			@sc5.write_attribute("c"+k.to_s, params[:systemcheck5]["c"+k.to_s])
		end
		
		sc1_arr = [32,34,36,38,39,40,41,42,45,46,47,48,50,53,56,57,58,2,3,4,5,6,8,11,14,92,94,95,96,97,98,100,101,103,104,106,107,
				109,110,112,113,114,25,24,26,27,28,29,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,
				86,87,88,89]
		sc1_arr.each do |k|
			@sc1.write_attribute("c"+k.to_s, params[:systemcheck1]["c"+k.to_s])
		end
		@sc1.save
		@sc5.save
		
		redirect_to(:action=>"profile2", :id=>params[:id], :sv=>1)
	end
	
	def profile3
		@current_menu = "profile3"
		@fund_information = Information.find(params[:id])
		@manager_id = ManagerToFund.find(:first, :conditions=>["FUND_ID = ?",@fund_information.id_1]).manager_id
		@manager_information = ManagerInformation.find(:first, :conditions=>["MANAGER_ID = ?", @manager_id])
		@system1 = Systeminformation1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@system2 = Systeminformation2.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@system5 = Systeminformation5.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		if @system5.nil?
			@system5 = Systeminformation5.new
			@system5.id_1=@fund_information.id_1
			@system5.save
		end
		@sc1 = Systemcheck1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@sc5 = Systemcheck5.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		
	end

	def profile3_save
		@fund_information = Information.find(params[:id])
		@system1 = Systeminformation1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@system2 = Systeminformation2.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@system5 = Systeminformation5.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		
		@fund_information.update_attributes(params[:information])
		@system1.update_attributes(params[:systeminformation1])
		@system2.update_attributes(params[:systeminformation2])
		@system5.update_attributes(params[:systeminformation5])
		@manager_id = ManagerToFund.find(:first, :conditions=>["FUND_ID = ?",@fund_information.id_1]).manager_id
		@manager_information = ManagerInformation.find(:first, :conditions=>["MANAGER_ID = ?", @manager_id])
		@manager_information.update_attributes(params[:manager_information])
		
		
		redirect_to(:action=>"profile3", :id=>params[:id], :sv=>1)
	end

	def userinfo0
		@current_menu = "user"
		@current_submenu = "userinfo0"
		@fund_information = Information.find(params[:id])
		@manager_id = ManagerToFund.find(:first, :conditions=>["FUND_ID = ?",@fund_information.id_1]).manager_id
		@manager_information = ManagerInformation.find(:first, :conditions=>["MANAGER_ID = ?", @manager_id])
		@system1 = Systeminformation1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@system2 = Systeminformation2.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@system5 = Systeminformation5.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@user1 = Userinformation1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		if @system5.nil?
			@system5 = Systeminformation5.new
			@system5.id_1=@fund_information.id_1
			@system5.save
		end
		@sc1 = Systemcheck1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@sc5 = Systemcheck5.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		
	end
	
	def userinfo1
		@current_menu = "user"
		@current_submenu = "userinfo1"
		@fund_information = Information.find(params[:id])
		@user4 = @fund_information.userinformation4
    @um1 = @fund_information.usermemo1
		@selected_user = User.find(:first, :conditions=>["id = ?", params[:user_id]])
		@manager_id = ManagerToFund.find(:first, :conditions=>["FUND_ID = ?",@fund_information.id_1]).manager_id
		if @selected_user.nil?
			mtp = ManagerToProfiles.find(:first, :conditions=>["manager_id = ?", @manager_id])
			if !mtp.nil?
				@selected_user = User.find(:first, :conditions=>["owner_id = ?", mtp.donor_id])
			else 
				@selected_user = User.new
			end
		end
		
		@manager_information = ManagerInformation.find(:first, :conditions=>["MANAGER_ID = ?", @manager_id])
		@system1 = Systeminformation1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@system2 = Systeminformation2.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@system5 = Systeminformation5.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		#@user1 = Userinformation1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
    @user1 = @fund_information.userinformation1
		if !@selected_user.nil?
			@g_donor = GDonorProfile.find(:first, :conditions=>["donor_id = ? ",@selected_user.owner_id])
			@g_address = GAddress.find(:first, :conditions=>["owner_id = ?",@selected_user.owner_id])
		end
		
		if @system5.nil?
			@system5 = Systeminformation5.new
			@system5.id_1=@fund_information.id_1
			@system5.save
		end
		@sc1 = Systemcheck1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@sc5 = Systemcheck5.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		
	end

	def userinfo1_save
		@fund_information = Information.find(params[:id])
    @old_f51 = @fund_information.f51
		@userinformation1 = @fund_information.userinformation1
    old_f30 = @userinformation1.f30
		@user4 = @fund_information.userinformation4
    #liquid_date = params[:information][:liquidation_date]
    #params[:information].delete(:liquidation_date)
    @userinformation1.greenwich350_index = params[:userinformation1][:greenwich350_index]
    @userinformation1.Ucits_index = params[:userinformation1][:Ucits_index]
    @userinformation1.aum_inc = params[:userinformation1][:aum_inc]
		@fund_information.update_attributes(params[:information])
		@userinformation1.update_attributes(params[:userinformation1])
    
    if @old_f51.to_s != @fund_information.f51
      @fund_information.f51_ts = Time.now
      @fund_information.f51_by = current_user.login
      @fund_information.save
    end
    
    if old_f30.to_s!=@userinformation1.f30.to_s
      @userinformation1.f30_ts = Time.now
      @userinformation1.f30_by = current_user.login
      @userinformation1.save
    end
#		if @userinformation1.f20.to_s.strip.blank?
#			@userinformation1.f20 = Time.now.strftime("%m/%d/%y")
#			@userinformation1.save
#		end
		
		@user4.update_attributes(params[:userinformation4])
@fund_information.liquidation_date = "#{params[:information]["liquidation_date(1i)"]}-#{params[:information]["liquidation_date(2i)"]}-01"

		
#		@fund_information.liquidation_date = params[:information][:liquidation_date]
		@fund_information.ceased_reporting = params[:information][:ceased_reporting]
		@fund_information.save
		redirect_to(:action=>"userinfo1", :id=>params[:id], :user_id=>params[:user_id], :sv=>1)
	end

	
	def userinfo2
		@current_menu = "user"
		@current_submenu = "userinfo2"
		@fund_information = Information.find(params[:id])
		
		@manager_id = ManagerToFund.find(:first, :conditions=>["FUND_ID = ?",@fund_information.id_1]).manager_id
		@manager_information = ManagerInformation.find(:first, :conditions=>["MANAGER_ID = ?", @manager_id])
		@system1 = Systeminformation1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@system2 = Systeminformation2.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@system5 = Systeminformation5.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@user1 = Userinformation1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@user2 = Userinformation2.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		
    if @user2.nil?
      @user2 = Userinformation2.new
      @user2.id_1 = @fund_information.id_1
      @user2.save
    end
    
		if @system5.nil?
			@system5 = Systeminformation5.new
			@system5.id_1=@fund_information.id_1
			@system5.save
		end
		@sc1 = Systemcheck1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@sc5 = Systemcheck5.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		
	end
	
	def userinfo2_save
		@fund_information = Information.find(params[:id])
		@userinformation2 = Userinformation2.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@fund_information.update_attributes(params[:information])
		@userinformation2.update_attributes(params[:userinformation2])
		redirect_to(:action=>"userinfo2", :id=>params[:id], :user_id=>params[:user_id], :sv=>1)
	end
	
	def userinfo3
		@current_menu = "user"
		@current_submenu = "userinfo3"
		@fund_information = Information.find(params[:id])
		
		@manager_id = ManagerToFund.find(:first, :conditions=>["FUND_ID = ?",@fund_information.id_1]).manager_id
		@manager_information = ManagerInformation.find(:first, :conditions=>["MANAGER_ID = ?", @manager_id])
		@system1 = Systeminformation1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@system2 = Systeminformation2.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@system5 = Systeminformation5.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@user1 = Userinformation1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@user2 = Userinformation2.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@user3 = Userinformation3.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@user4 = Userinformation4.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		if @user3.nil?
			@user3 = Userinformation3.new
			@user3.id_1 = @fund_information.id_1
			@user3.save
		end
		
		if @system5.nil?
			@system5 = Systeminformation5.new
			@system5.id_1=@fund_information.id_1
			@system5.save
		end
		@sc1 = Systemcheck1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@sc5 = Systemcheck5.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		
	end
	
	def userinfo3_save
		@fund_information = Information.find(params[:id])
		@userinformation3 = Userinformation3.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@fund_information.update_attributes(params[:information])
		@userinformation3.update_attributes(params[:userinformation3])
		redirect_to(:action=>"userinfo3", :id=>params[:id], :user_id=>params[:user_id], :sv=>1)
	end
	
	def userinfo4
		@current_menu = "user"
		@current_submenu = "userinfo4"
		@fund_information = Information.find(params[:id])
	
		@manager_id = ManagerToFund.find(:first, :conditions=>["FUND_ID = ?",@fund_information.id_1]).manager_id
		@manager_information = ManagerInformation.find(:first, :conditions=>["MANAGER_ID = ?", @manager_id])
		@system1 = Systeminformation1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@system2 = Systeminformation2.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@system5 = Systeminformation5.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@user1 = Userinformation1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@user2 = Userinformation2.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@user3 = Userinformation3.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@user4 = Userinformation4.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		if @user3.nil?
			@user3 = Userinformation3.new
			@user3.id_1 = @fund_information.id_1
			@user3.save
		end
		
		if @system5.nil?
			@system5 = Systeminformation5.new
			@system5.id_1=@fund_information.id_1
			@system5.save
		end
		@sc1 = Systemcheck1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@sc5 = Systemcheck5.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		
	end

	def userinfo4_save
		@fund_information = Information.find(params[:id])
		@userinformation4 = Userinformation4.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@fund_information.update_attributes(params[:information])
		@userinformation4.update_attributes(params[:userinformation4])
		redirect_to(:action=>"userinfo4", :id=>params[:id], :user_id=>params[:user_id], :sv=>1)
	end

	
	def userinfo5
		@current_menu = "user"
		@current_submenu = "userinfo5"
		@fund_information = Information.find(params[:id])
		
		@manager_id = ManagerToFund.find(:first, :conditions=>["FUND_ID = ?",@fund_information.id_1]).manager_id
		@manager_information = ManagerInformation.find(:first, :conditions=>["MANAGER_ID = ?", @manager_id])
		@system1 = Systeminformation1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@system2 = Systeminformation2.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@system5 = Systeminformation5.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@user1 = Userinformation1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@user2 = Userinformation2.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@user3 = Userinformation3.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@user4 = Userinformation4.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		if @user3.nil?
			@user3 = Userinformation3.new
			@user3.id_1 = @fund_information.id_1
			@user3.save
		end
		
		if @system5.nil?
			@system5 = Systeminformation5.new
			@system5.id_1=@fund_information.id_1
			@system5.save
		end
		@sc1 = Systemcheck1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@sc5 = Systemcheck5.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@uc2 = Usercheck2.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
	end
	
	def userinfo5_save
		@fund_information = Information.find(params[:id])
		@usercheck2 = Usercheck2.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		uc2_arr = [1,2,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36]
		uc2_arr.each do |k|
			@usercheck2.write_attribute("c"+k.to_s, params[:usercheck2]["c"+k.to_s])
		end
		@usercheck2.save
		redirect_to(:action=>"userinfo5", :id=>params[:id], :user_id=>params[:user_id], :sv=>1)
	end
	
	def userinfo6
		@current_menu = "user"
		@current_submenu = "userinfo6"
		@fund_information = Information.find(params[:id])
		
		@manager_id = ManagerToFund.find(:first, :conditions=>["FUND_ID = ?",@fund_information.id_1]).manager_id
		@manager_information = ManagerInformation.find(:first, :conditions=>["MANAGER_ID = ?", @manager_id])
		@system1 = Systeminformation1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@system2 = Systeminformation2.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@system5 = Systeminformation5.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@user1 = Userinformation1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@user2 = Userinformation2.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@user3 = Userinformation3.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@user4 = Userinformation4.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		if @user3.nil?
			@user3 = Userinformation3.new
			@user3.id_1 = @fund_information.id_1
			@user3.save
		end
		
		if @system5.nil?
			@system5 = Systeminformation5.new
			@system5.id_1=@fund_information.id_1
			@system5.save
		end
		@sc1 = Systemcheck1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@sc5 = Systemcheck5.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@uc2 = Usercheck2.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		#@um1 = Usermemo1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
    @um1 = @fund_information.usermemo1
	end
	
	
	def userinfo6_save
		@fund_information = Information.find(params[:id])
		@usermemo1 = Usermemo1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		
		@usermemo1.update_attributes(params[:usermemo1])
		redirect_to(:action=>"userinfo6", :id=>params[:id], :user_id=>params[:user_id], :sv=>1)
	end
	
	def profile
		@user = current_user
		@g_donor = GDonorProfile.find(:first, :conditions=>["donor_id = ? ",current_user.owner_id])
		if @g_donor.nil?
			@g_donor = GDonorProfile.new
			@g_donor.donor_id = current_user.owner_id
			@g_donor.save
		end
		
		
		@g_address = GAddress.find(:first, :conditions=>["owner_id = ?",current_user.owner_id])
		if @g_address.nil?
			@g_address = GAddress.new
			@g_address.owner_id = current_user.owner_id
			@g_address.addr_id = GAddress.find(:first, :order=>"addr_id desc").addr_id.to_i + 1
			@g_address.save
		end
	end
	
	def profile_save
		@user = current_user
		
		@g_donor = GDonorProfile.find(:first, :conditions=>["donor_id = ? ",current_user.owner_id])
		@g_address = GAddress.find(:first, :conditions=>["owner_id = ?",current_user.owner_id])
    @g_address.attributes = params[:g_address]
    @g_donor.attributes = params[:g_donor_profile]
    params[:user][:phone_number] = params[:g_address][:phone]
    if @user.update_attributes(params[:user])
      @g_donor.update_attributes(params[:g_donor_profile])
      @g_donor.first_name = @user.first_name
      @g_donor.last_name = @user.last_name
      @g_donor.save
      @g_address.update_attributes(params[:g_address])
      @g_address.email = @user.email
      @g_address.save
      redirect_to :action=>"profile", :sv=>1
		else 
      render :action=>:profile
    end
    
		
	end
	
	def fund_strategyB
		@current_menu = "fund_strategy"
		@fund_information = Information.find(params[:id])
		@manager_id = ManagerToFund.find(:first, :conditions=>["FUND_ID = ?",@fund_information.id_1]).manager_id
		@manager_information = ManagerInformation.find(:first, :conditions=>["MANAGER_ID = ?", @manager_id])
		@system1 = Systeminformation1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@st_gr = [["Other",'']]+ElemOfSet.find(:all, :include=>"set_of_set", :conditions=>["set_of_sets.name=?", "strategy_group"]).map {|c| c.name }
	end
	
	def fund_strategyC
		@current_menu = "fund_strategy"
		@fund_information = Information.find(params[:id])
		@usercheck7 = @fund_information.usercheck7
		@manager_id = ManagerToFund.find(:first, :conditions=>["FUND_ID = ?",@fund_information.id_1]).manager_id
		@manager_information = ManagerInformation.find(:first, :conditions=>["MANAGER_ID = ?", @manager_id])
		@system1 = Systeminformation1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		@st_gr = [["Other",0]]+ElemOfSet.find(:all, :include=>"set_of_set", :conditions=>["set_of_sets.name=?", "strategy_group"]).map {|c| c.name }
		
	end
	
	def fund_strategyB_save
		@fund_information = Information.find(params[:id])
		@system1 = Systeminformation1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
		
		if @fund_information.f49.to_s!=params[:information][:f49].to_s
				@fund_information.set_strategies(params[:information][:f49].to_s)
				@usercheck7 = @fund_information.usercheck7
				@usercheck7.update_f49(params[:information][:f49].to_s)	if @fund_information.manual_edit!=1
		end
		
		if @fund_information.f38.to_s!=params[:information][:f38].to_s
				@usercheck7 = @fund_information.usercheck7
				@usercheck7.update_f38(params[:information][:f38].to_s)	if @fund_information.manual_edit!=1
		end
		
		if @fund_information.f40.to_s!=params[:information][:f40].to_s
				@usercheck7 = @fund_information.usercheck7
				@usercheck7.update_f40(params[:information][:f40].to_s)	if @fund_information.manual_edit!=1
		end
		
		if @fund_information.f48.to_s!=params[:information][:f48].to_s
				@usercheck7 = @fund_information.usercheck7
				@usercheck7.update_f48(params[:information][:f48].to_s)	if @fund_information.manual_edit!=1
		end
		
		if @fund_information.f41.to_s!=params[:information][:f41].to_s
				@usercheck7 = @fund_information.usercheck7
				@usercheck7.update_f41(params[:information][:f41].to_s)	if @fund_information.manual_edit!=1
		end
		
		@fund_information.update_attributes(params[:information])
		@fund_information.f38 = params[:over_information][:f38] if !params[:over_information][:f38].strip.blank?
		@fund_information.f40 = params[:over_information][:f40] if !params[:over_information][:f40].strip.blank?
		@fund_information.f41 = params[:over_information][:f41] if !params[:over_information][:f41].strip.blank?
		@fund_information.f48 = params[:over_information][:f48] if !params[:over_information][:f48].strip.blank?
		
		
		#@fund_information.f15 = params[:over_information][:f15] if params[:information][:f15].to_s=="other"
		#@fund_information.f37 = params[:over_information][:f37] if params[:information][:f37].to_s=="0"
		#@fund_information.f39 = params[:over_information][:f39] if params[:information][:f39].to_s=="0"
		@fund_information.save
		
		
		if @fund_information.manual_edit==1
			Message.to_admins("Manually edited fund "+@fund_information.f20.to_s+" has been modified. Click <a href='/my/fund_strategyC?id="+@fund_information.id.to_s+"'>here</a> to access the manual edit interface.",1)
		end
		
		@system1.update_attributes(params[:systeminformation1])
		@manager_id = ManagerToFund.find(:first, :conditions=>["FUND_ID = ?",@fund_information.id_1]).manager_id
		@manager_information = ManagerInformation.find(:first, :conditions=>["MANAGER_ID = ?", @manager_id])
		@manager_information.update_attributes(params[:manager_information])
		
		
		
		@fund_information.save
		flash[:sv] = 1
		redirect_to(:action=>"fund_strategyB", :id=>params[:id])
	end
	
	def fund_strategyC_save
		@fund_information = Information.find(params[:id])
		@usercheck7 = @fund_information.usercheck7
		@fund_information.manual_edit = 1
    
		@fund_information.in_calc = (!params[:information].nil? ? params[:information][:in_calc] : 0)
		@fund_information.save
		(1..100).each do |k|
		    a = 0
		    a = params[:usercheck7]["c"+k.to_s] if !params[:usercheck7].nil? and !params[:usercheck7]["c"+k.to_s].nil?
			@usercheck7.write_attribute("c"+k.to_s, a) 
		end
		@usercheck7.save
		#@usercheck7.update_attributes(params[:usercheck7])
		
		flash[:sv] = 1
		redirect_to(:action=>"fund_strategyC", :id=>params[:id])
	end
	
	def fs_sel1b
		@fund_information = Information.find(params[:id])
		@st_se = [["None","None"]] 
		sos = SetOfSet.find(:first, :conditions=>["name=?",params[:st_gr]])
		if !sos.nil?
          @st_se = @st_se + sos.elem_of_sets.map{|c| c.name}
        end
    @st_se = @st_se + [["Other",""]]
		render :layout=>false
	end
	def fs_sel2b
		@fund_information = Information.find(params[:id])
    @st_se = Array.new
		sos = SetOfSet.find(:first, :conditions=>["name=?",params[:st_gr]])
		if sos.nil? || sos.elem_of_sets.map{|c| c.name}.index("None").nil?
		  @st_se = @st_se + [["None", "None"]]
		end
		if !sos.nil?
      @st_se = @st_se + sos.elem_of_sets.map{|c| c.name}
    end
    if sos.nil? || sos.elem_of_sets.map{|c| c.name}.index("Other").nil?
      @st_se = @st_se + [["Other", ""]]
    end
 		render :layout=>false
	end	
	
	def cancel_manual_edit
		@fund_information = Information.find(params[:id])
		@usercheck7 = @fund_information.usercheck7
		@usercheck7.update_f49(@fund_information.f49)
		@usercheck7.update_f38(@fund_information.f38)
		@usercheck7.update_f40(@fund_information.f40)
		@usercheck7.update_f48(@fund_information.f48)
		@usercheck7.update_f41(@fund_information.f41)
		@fund_information.manual_edit = nil
		@fund_information.save
		redirect_to(:action=>"fund_strategyC", :id=>params[:id])
  end

  def create_fundsmistake
    @user = current_user
    @fundmistake = Fundmistake.new
    @fundmistake.datemistake = Time.now
    @fundmistake.user_id = @user.id
    @fundmistake.user_login = @user.login
    @fundmistake.fund_name = params[:fund_name]
    @fundmistake.fund_id = params[:fund_id]
    @fundmistake.save
    render :json => @fundmistake
  end

  # def get_informations
  #   @informations = []
  #   session[:fund_name] = params[:fund_name] if !params[:fund_name].to_s.blank?
  #   params[:fund_name] = session[:fund_name] if params[:fund_name].to_s.blank?
  #   if current_user.tip=="member"
  #       ManagerToFund.find(:all, :conditions=>["MANAGER_ID = ?", current_user.manager_id]).each do |mtf|
  #         Information.find(:all, :conditions=>["ID_1 = ? and upper(F20) not like ? and upper(F20) not like ? and upper(F20) not like ? and upper(F20) not like ? and F51 like ?", mtf.fund_id, "%DELETE%", "%WRI%","%DUPLICATE%","%DEFUNCT%", "Master List"]).each do |information|
  #           ui4 = information.userinformation4
  #           if information.f51 == "Master List"
  #             @informations << information 
  #           end
  #         end 
  #       end
  #   end
  #   if current_user.tip=="admin" or current_user.tip=="data_entry" || current_user.tip=="data_entry2"
  #       if params[:fund_name]
  #         Information.all(:conditions=>["upper(F20) like ?", "%"+params[:fund_name].upcase+"%"], :order=>"F20", :limit=>100).each do |information|
  #           @informations << information
  #         end
  #       end
  #   end    
  # end

  def get_informations
    @informations = []
    session[:fund_name] = params[:fund_name] if !params[:fund_name].to_s.blank?
    params[:fund_name] = session[:fund_name] if params[:fund_name].to_s.blank?
    if current_user.tip=="member"
        ManagerToFund.find(:all, :conditions=>["MANAGER_ID = ?", current_user.manager_id]).each do |mtf|
          Information.find(:all, :conditions=>["ID_1 = ? and upper(F20) not like ? and upper(F20) not like ? and upper(F20) not like ? and upper(F20) not like ? and F51 like ?", mtf.fund_id, "%DELETE%", "%WRI%","%DUPLICATE%","%DEFUNCT%", "Master List"]).each do |information|
            ui4 = information.userinformation4
            @informations << information 
          end 
        end
    end
    if current_user.tip=="admin" or current_user.tip=="data_entry" || current_user.tip=="data_entry2"
        if params[:fund_name]
          Information.all(:conditions=>["upper(F20) like ?", "%"+params[:fund_name].upcase+"%"], :order=>"F20", :limit=>100).each do |information|
            @informations << information
          end
        end
    end 
  end  
end
