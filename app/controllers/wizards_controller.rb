class WizardsController < ApplicationController
  def new
    @wizard = Wizard.new
    if !params[:step].nil?
      session[:wizard_step] = @wizard.steps[params[:step].to_i]
    end
    @wizard.current_step = session[:wizard_step]
    if @wizard.first_step?
      date_fmt = "%Y-%m%-%d"
      date_tpl = "?"

      @limit_items = params[:limit]||50

      @span_period = params[:span_period] || "month"
      @fund_information = Information.find(params[:id])
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

      if !params[:ds_form_date_1i].nil? && !params[:ds_form_date_2i].nil? && !params[:ds_form_date_3i].nil?
        @date2 = params[:ds_form_date_1i]+"-"+params[:ds_form_date_2i]+"-"+params[:ds_form_date_3i]
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
        @dts << Time.now
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
        elements_v2[element.date_1.strftime("%Y%m%d")] = element
      end
      @datefmt = @dts.last.strftime("%Y")
      @perf_vals = elements_v2
      @elements = elements

    elsif @wizard.current_step== @wizard.steps[1]
      @fund_information = Information.find(params[:id])
      @manager_id = ManagerToFund.find(:first, :conditions=>["FUND_ID = ?",@fund_information.id_1]).manager_id
      @manager_information = ManagerInformation.find(:first, :conditions=>["MANAGER_ID = ?", @manager_id])
      @system1 = Systeminformation1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
    elsif @wizard.current_step== @wizard.steps[2]
      @fund_information = Information.find(params[:id])
      @user2 = @fund_information.userinformation2
      @sc5 = @fund_information.systemcheck5
      @manager_id = ManagerToFund.find(:first, :conditions=>["FUND_ID = ?",@fund_information.id_1]).manager_id
      @manager_information = ManagerInformation.find(:first, :conditions=>["MANAGER_ID = ?", @manager_id])
      @system1 = @fund_information.systeminformation1
    elsif @wizard.current_step== @wizard.steps[3]
      @fund_information = Information.find(params[:id])
      @manager_id = ManagerToFund.find(:first, :conditions=>["FUND_ID = ?",@fund_information.id_1]).manager_id
      @manager_information = ManagerInformation.find(:first, :conditions=>["MANAGER_ID = ?", @manager_id])
      @system1 = Systeminformation1.find(:first, :conditions=>["id_1=?", @fund_information.id_1])
      @st_gr = [["Other",'']]+ElemOfSet.find(:all, :include=>"set_of_set", :conditions=>["set_of_sets.name=?", "strategy_group"]).map {|c| c.name }
    end

  end

  def do_step
    @wizard = Wizard.new
    @wizard.current_step = session[:wizard_step]

    if @wizard.first_step?
      if params[:back_button].nil? && (params[:systeminformation1][:f36].blank? || params[:systeminformation1][:f28].blank? || params[:information][:f35].blank?)
        flash[:notice] = "Please fill in the required fields before proceeding"
      else 
        flash[:notice] = nil
      end
      cls=Performance
      cls=Dailydata if params[:span_period]=="week"
      cls=DailydataDay if params[:span_period]=="day"
      @fund = Information.find(params[:id])
      @other_funds = @fund.other_funds_in_firm
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
      @system1.f11 = params[:systeminformation1][:f11]
      @system1.f27 = number_to_currency(params[:systeminformation1][:f27].to_f*1000000, :precision=>0).gsub("$","")
      @system1.f27 = nil if @system1.f27.to_f.to_s == ("0.0")
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
    elsif @wizard.current_step== @wizard.steps[1]
      if params[:back_button].nil? && (params[:information][:f2].blank? || params[:information][:f4].blank? ||  params[:information][:f7].blank? || params[:information][:f9].blank? || params[:information][:f11].blank? || params[:information][:f12].blank?)
        flash[:notice] = "Please fill in the required fields before proceeding"
      else 
        flash[:notice] = nil
      end
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
    elsif @wizard.current_step== @wizard.steps[2]
      if params[:back_button].nil? && (params[:systeminformation1][:f49].to_s.blank? || params[:information][:f14].blank?  || params[:information][:f22].blank? ||  params[:information][:f24].blank?  || params[:information][:f23].blank? || params[:information][:f25].blank? || params[:information][:f27].blank? || params[:information][:f28].blank? || params[:information][:f29].blank?)
        flash[:notice] = "Please fill in the required fields before proceeding"
      else 
        flash[:notice] = nil
      end
      @fund_information = Information.find(params[:id])
      old_f20 = @fund_information.f20
      @user2 = @fund_information.userinformation2
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
      flash[:sv] = 1
    elsif @wizard.current_step== @wizard.steps[3]
      @fund_information = Information.find(params[:id])
      if params[:back_button].nil? && (params[:information][:f38].blank? || params[:information][:f40].blank? ||  params[:information][:f49].nil?)
        flash[:notice] = "Please fill in the required fields before proceeding"
      elsif params[:back_button].nil?
        @fund_information.finished = true
        flash[:notice] = nil
      else
        flash[:notice] = nil
      end
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
    end

    if params[:logout]
      session[:wizard_step] = nil
      redirect_to :controller => 'user_sessions', :action => 'destroy'
    elsif !flash[:notice].nil? && !flash[:notice].blank?
      redirect_to :action=>"new", :id=>params[:id]
    elsif params[:back_button]
      @wizard.previous_step
      session[:wizard_step] = @wizard.current_step
      redirect_to :action=>"new", :id=>params[:id]
    elsif @wizard.last_step?
      session[:wizard_step] = nil
      redirect_to :controller => "my", :action => "index"
    else
      @wizard.next_step
      session[:wizard_step] = @wizard.current_step
      redirect_to :action=>"new", :id=>params[:id]
    end
  end

  def fs_sel1
    @fund_information = Information.find(params[:id])
    @st_pr = [["Other",""]]+ElemOfSet.find(:all, :include=>"set_of_set", :conditions=>["set_of_sets.name=?", params[:st_gr]]).map {|c| c.name }
    render :layout=>false
  end
  def fs_sel2
    @fund_information = Information.find(params[:id])
    @st_se = [["Other",""]]+ElemOfSet.find(:all, :include=>"set_of_set", :conditions=>["set_of_sets.name=?", params[:st_pr]]).map {|c| c.name }
    render :layout=>false
  end

  def fs_sel1b
    @fund_information = Information.find(params[:id])
    @st_se = [["[Select]",""],["Other","other"]]
    sos = SetOfSet.find(:first, :conditions=>["name=?",params[:st_gr]])
    if !sos.nil?
      @st_se = @st_se + sos.elem_of_sets.map{|c| c.name}
    end
    @st_se = @st_se + [["None","None"]]
    render :layout=>false
  end

  def fs_sel2b
    @fund_information = Information.find(params[:id])
    @st_se = [["[Select]",""],["Other","other"]]
    sos = SetOfSet.find(:first, :conditions=>["name=?",params[:st_gr]])
    if !sos.nil?
      @st_se = @st_se + sos.elem_of_sets.map{|c| c.name}
    end
    @st_se = @st_se + [["None","None"]]
    render :layout=>false
  end
end
