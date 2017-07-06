class FundsController < ApplicationController
  #before_filter :login_required, :except=>["index_json"]
  after_filter :do_log
  
  def do_log
    LogEvent.new(:c=>request.parameters['controller'],:m=>request.parameters['action'], :p=>request.parameters.to_param, :user_id=>(current_user.nil? ? nil : current_user.id)).save
  end
    
  def index_json
    filters = params[:filter] || []
    cond1 = []
    cond2 = []
    filters.each do |k,filter_arr|
#     if (filter_arr[:field] =~ /^g_addresses/).nil?
          cond1 << "upper(information."+filter_arr[:field]+") like ?"
#     end

#     if !(filter_arr[:field] =~ /^g_addresses/).nil?
#         cond1 << "g_addresses."+filter_arr[:field].gsub("g_addresses_","")+" like ?" 
#     end

      cond2 << "%"+filter_arr[:data][:value].upcase+"%"
    end
    cond1 = cond1.join(" and ")
    
    cond_final = []
    cond_final << cond1
    cond_final = cond_final + cond2
    
    limit = params[:limit] ? params[:start]+","+params[:limit] : ""
    
#   if !(params[:sort] =~ /^g_addresses/).nil?
#     params[:sort] = "g_addresses."+params[:sort]
#   elsif params[:sort].to_s.size>0
#     params[:sort] = "users."+params[:sort]
#   end
    
    funds = Information.find(:all, :order=>params[:sort]+" "+params[:dir], :conditions=>cond_final, :limit=>limit)
    hsh = {}
    hsh[:total] = Information.count
    hsh[:data] = []
    
    funds.each do |fund|
      dt = {}
      dt[:f20] = fund.f20
      dt[:in_calc] = fund.in_calc
      dt[:id] = fund.id
    dt[:id_1] = fund.id_1
      hsh[:data] << dt
    end

    render :text=>hsh.to_json
  end
  
  
  def add
    @information = Information.new
  end
  
  def do_add
    error = {:status=> false, :message => nil, :type => nil}
    #render :text=>params[:firm_id]
    @li_di = Information.find(:first, :order=>"datavendorid+1 desc")
    if params[:firm_id]
      @manager_information = ManagerInformation.find(params[:firm_id])
    else
      @manager_information = current_user.firm  
    end
    @information = Information.new(params[:information])
    @information.manager_id = @manager_information.id
    @information.datavendorname="VAN"
    @information.datavendorid = Seq.get_one("datavendorid")
    @information.lastupdated = Time.now
    #@information.f20 = params[:information][:f20]
    #@information.f21 = params[:information][:f21].to_time
    @information.f1 = @manager_information.general_partner
    @information.f2 = @manager_information.address1
    @information.f3 = @manager_information.address2 
    @information.f4 = @manager_information.city
    @information.f5 = @manager_information.state_province
    @information.f6 = @manager_information.zip 
    @information.f7 = @manager_information.country
    @information.f9 = @manager_information.phone
    @information.f10 = @manager_information.fax 
    @information.f11 = @manager_information.email
    @information.f12 = @manager_information.contact_person
    @information.f13 = @manager_information.contact_title
    @information.f18 = @manager_information.website
    @information.f34 = @manager_information.firm_assets
    @information.id_1 =  Settings.manager_id = Settings.manager_id.to_i + 1
    @information.in_calc = 1
    @information.f51 = "Master List"
    @information.added_by = current_user.login
    @information.finished = false;
    
    @system1 = @information.systeminformation1
    @system5 = @information.systeminformation5
    
    if current_user.tip !="admin"
      unless current_user.owner_id > 0
        error = {:status => true, :type => :user_no_firm_associated ,:message => 'Your User account does not appear to be associated with a Firm ID number in our database. This system error has been sent to our Data Team and one of us will get back you shortly with a fix. Thank you for your patience.'}
      else
        manager_to_profile = ManagerToProfiles.find(:first, :conditions=>["donor_id = ?",current_user.owner_id])
        params[:firm_id] = ManagerInformation.find(:first, :conditions=>["manager_id = ?", manager_to_profile.manager_id]).id if  manager_to_profile

        error = {:status => true, :type => :user_manager_information ,:message => 'Your User account does not appear to be associated with a Firm ID number in our database. This system error has been sent to our Data Team and one of us will get back you shortly with a fix. Thank you for your patience.'} if params[:firm_id].blank?
      end
    end
    app_logger error
    if error[:status]
      if error[:type] == :user_no_firm_associated || error[:type] == :user_no_firm_associated
        email_error_message = "The following user encountered the NoMethodError message related to the “Donor ID” field:
                                id: #{current_user.id}
                                login: #{current_user.login}
                                name: #{current_user.name}
                                first name: #{current_user.first_name}
                                last name: #{current_user.last_name}
                                email: #{current_user.email}
                                phone number: #{current_user.phone_number}
                                created at: #{current_user.created_at}
                                owner id: #{current_user.owner_id}
                                active: #{current_user.active}"
        Emailer.deliver_message('wiktor.bobowski@polcode.net', "Greenwich Database Account Error",email_error_message)
        Emailer.deliver_message('data@greenwichai.com', "Greenwich Database Account Error",email_error_message)
      end
      flash[:alert] = error[:message]
      redirect_to root_path
    else
      mtf = ManagerToFund.new
      mtf.manager_id = ManagerInformation.find(params[:firm_id]).manager_id
      begin
        if !@information.att1.path.nil?
          if(@information.att1.path.include?(".xls") && !@information.att1.path.include?(".xlsx"))
            require 'parseexcel'

            @information.save
            @information.make_init

            @workbookA = Spreadsheet::ParseExcel.parse(@information.att1.path)

            #Validation of Spreadsheet
            if !@workbookA.nil?
              @worksheetA = @workbookA.worksheet(0)
              dates = []
              @worksheetA.each { |row|
                if !row.nil? and !row[0].nil? and !row[0].date.blank? and row[0].date.to_time.day == row[0].date.to_time.end_of_month.day and !row[1].nil?

                  validation = true
                  p = Performance.new
                  p.date_1 = row[0].date.to_time.end_of_month.strftime("%Y-%m-%d") if !row[0].nil? and !row[0].date.blank?
                  p.return = row[1].to_s("latin1") if !row[1].nil?
                  begin
                    Float(row[1].to_s("latin1")) if !row[1].nil? and !row[1].value.blank?
                    Float(row[2].to_s("latin1")) if !row[2].nil? and !row[2].value.blank?
                    Float(row[3].to_s("latin1")) if !row[3].nil? and !row[3].value.blank?
                    Float(row[4].to_s("latin1")) if !row[4].nil? and !row[4].value.blank?
                    Float(row[5].to_s("latin1")) if !row[5].nil? and !row[5].value.blank?
                    Float(row[6].to_s("latin1")) if !row[6].nil? and !row[6].value.blank?
                  rescue Exception => exc
                    validation = false
                    flash[:notice] = "There are problems with your data. There are text values in the spreadsheet. Please include only numbers or symbols. Text may only be present in the headings. Please check your spreadsheet values and try again. If you need assistance, please contact ​data@greenwichai.com or call +1.203.487.6180."
                  end

                  if !p.date_1.nil? && p.date_1 < Date.new(1970,1,1)
                    validation = false
                    flash[:notice] = "There are problems with your data. The dates cannot be before 1970. Please check your spreadsheet values and try again. If you need assistance, please contact ​data@greenwichai.com or call +1.203.487.6180."
                  elsif !p.return.nil? && (p.return > 2 || p.return < -2)
                    validation = false
                    flash[:notice] = "There are problems with your data. The return cannot be lower than -200% or higher than 200%. Please check your spreadsheet values and try again. If you need assistance, please contact ​data@greenwichai.com or call +1.203.487.6180."
                  elsif !p.date_1.nil? && p.date_1 > Time.now.months_ago(1).end_of_month
                    validation = false
                    flash[:notice] = "There are problems with your data. The date cannot be higher than one month ago. Please check your spreadsheet values and try again. If you need assistance, please contact ​data@greenwichai.com or call +1.203.487.6180."
                  elsif !p.date_1.nil? && dates.include?(p.date_1)
                    validation = false
                    flash[:notice] = "There are problems with your data. At least one date appears more than once. Please check your spreadsheet values and try again. If you need assistance, please contact ​data@greenwichai.com or call +1.203.487.6180."
                  end

                  dates<<p.date_1

                  if !validation
                    break
                  end

                end
              }
            end



            if !@workbookA.nil?
              @worksheetA = @workbookA.worksheet(0)
              @worksheetA.each { |row|
                if !row.nil? and !row[0].nil? and !row[0].date.blank? and row[0].date.to_time.day == row[0].date.to_time.end_of_month.day and !row[1].nil?
                  p = Performance.new
                  p.id_1 = @information.id_1
                  p.date_1 = row[0].date.to_time.end_of_month.strftime("%Y-%m-%d") if !row[0].nil? and !row[0].date.blank?
                  p.return = row[1].to_s("latin1") if !row[1].nil?
                  p.fundsmanaged = row[2].to_s("latin1") if !row[2].nil?
                  p.firm_aum = row[3].to_s("latin1") if !row[3].nil?
                  p.gross_exposure = (!row[4].nil? and !row[4].to_s("latin1").empty?) ? row[4].to_s("latin1").to_f*100 : nil
                  p.nav = row[5].to_s("latin1") if !row[5].nil?
                  p.estimate = row[6].to_s("latin1").strip if !row[6].nil?
                  p.lastupdated = Time.now



                  #pf = Performance.find(:first, :conditions=>["id_1 in (?) and date_1 = ?", @of.map{|c| c.id_1},p.date_1])
                  #f_firm_aum = ""
                  #f_firm_aum = pf.firm_aum if !pf.nil?
                  #p.firm_aum = !pcrp[5].to_s.strip.blank? ? pcrp[5] : f_firm_aum

                  p.save if !p.date_1.nil?

                end
              }
            end
          else
            flash[:notice] = "Monthly Data File format incorrect. Please upload performance in XLS format (Excel 97-2003)"
          end
        else
          @information.save
          @information.make_init
        end
      rescue Exception => exc
        flash[:notice] = "Errors reading the file"
      end
      if !flash[:notice].nil? && !flash[:notice].blank? && !flash[:notice] != "error"
        render "add"
      else
        mtf.fund_id = @information.id_1

        mtf.save

        if current_user.tip!="admin"
          Message.to_admins("<a target='nwwin' href='/users/"+current_user.id.to_s+"/edit'>"+current_user.login.to_s+"</a> added a new fund '"+@information.f20.to_s+"' ["+ManagerInformation.find(params[:firm_id]).general_partner.to_s+"]  on "+Time.now.strftime("%Y-%m-%d")+".",1)
          redirect_to :controller=>"wizards", :action=>"new", :id=>@information.id, :step=> "0"
        else
          redirect_to :controller=>"my", :action=>"perfs", :id=>@information.id
        end
      end
    end
  end
  
  
  def search_firm
    mis = ManagerInformation.find(:all, :conditions=>["upper(general_partner) like ?", "%"+params[:name].upcase+"%"], :limit=>100)
    ret_text = "<select name='firm_id'>"
    mis.each do |mi|
      ret_text = ret_text + "<option value='"+mi.id.to_s+"'>"+mi.general_partner+"</option>"
    end
    ret_text = ret_text + "</select>"
    render :text=>ret_text
  end
  
  
  
  def new
    @information = Information.new
  end
  
  def edit
    @information = Information.find(params[:id])
    render :action=>"new"
  end
  
  def create
    @manager_information = ManagerInformation.find(params[:firm_id])
    @information = Information.new(params[:information])
    @information.manager_id = @manager_information.id
    @information.id_1 =  Settings.manager_id = Settings.manager_id.to_i + 1
    @information.datavendorname = "VAN"
    @information.datavendorid = Seq.get_one("datavendorid")
    @information.lastupdated = Time.now
    @information.f2 = @manager_information.address1
    @information.f3 = @manager_information.address2 
    @information.f4 = @manager_information.city
    @information.f5 = @manager_information.state_province
    @information.f6 = @manager_information.zip 
    @information.f7 = @manager_information.country
    @information.f9 = @manager_information.phone
    @information.f10 = @manager_information.fax 
    @information.f11 = @manager_information.email
    @information.f12 = @manager_information.contact_person
    @information.f13 = @manager_information.contact_title
    @information.f18 = @manager_information.website
    @information.f34 = @manager_information.firm_assets
    @information.f1 = @manager_information.general_partner
    @information.f51 = "Master List"
    @information.added_by = current_user.login
    @information.in_calc = 1

    #@information.save
    #@information.make_init
    
        
    mtf = ManagerToFund.new
    mtf.fund_id = @information.id_1
    mtf.manager_id = @manager_information.manager_id
    
    
    @of = @information.other_funds_in_firm
    begin
      if !params[:upload].nil? and !params[:upload][:datafile].nil?
        if params[:upload][:datafile].original_path.include?(".xls") && !params[:upload][:datafile].original_path.include?(".xlsx")
          fls = params[:upload][:datafile]
          require 'parseexcel'
          
          @workbookA = Spreadsheet::ParseExcel.parse(params[:upload][:datafile].path) if !params[:upload][:datafile].nil?
          
          #Validation of Spreadsheet
          if !@workbookA.nil?
            @worksheetA = @workbookA.worksheet(0)
            dates = []
            @worksheetA.each { |row|
            if !row.nil? and !row[0].nil? and !row[0].date.blank? && row[0].date.to_time.day == row[0].date.to_time.end_of_month.day and !row[1].nil?
              
              validation = true
              p = Performance.new
              p.date_1 = row[0].date.to_time.end_of_month.strftime("%Y-%m-%d") if !row[0].nil? and !row[0].date.blank?
              p.return = row[1].to_s("latin1") if !row[1].nil?
              begin
                Float(row[1].to_s("latin1")) if !row[1].nil? and !row[1].value.blank?
                Float(row[2].to_s("latin1")) if !row[2].nil? and !row[2].value.blank?
                Float(row[3].to_s("latin1")) if !row[3].nil? and !row[3].value.blank?
                Float(row[4].to_s("latin1")) if !row[4].nil? and !row[4].value.blank?
                Float(row[5].to_s("latin1")) if !row[5].nil? and !row[5].value.blank?
                Float(row[6].to_s("latin1")) if !row[6].nil? and !row[6].value.blank?
              rescue Exception => exc
                validation = false
                flash[:notice] = "There are problems with your data. There are text values in the spreadsheet. Please include only numbers or symbols. Text may only be present in the headings. Please check your spreadsheet values and try again. If you need assistance, please contact ​data@greenwichai.com or call +1.203.487.6180."
              end
              
              if !p.date_1.nil? && p.date_1 < Date.new(1970,1,1)
                validation = false 
                flash[:notice] = "There are problems with your data. The dates cannot be before 1970. Please check your spreadsheet values and try again. If you need assistance, please contact ​data@greenwichai.com or call +1.203.487.6180."
              elsif !p.return.nil? && (p.return > 2 || p.return < -2)
                validation = false
                flash[:notice] = "There are problems with your data. The return cannot be lower than -200% or higher than 200%. Please check your spreadsheet values and try again. If you need assistance, please contact ​data@greenwichai.com or call +1.203.487.6180."
              elsif !p.date_1.nil? && p.date_1 > Time.now.months_ago(1).end_of_month
                validation = false 
                flash[:notice] = "There are problems with your data. The date cannot be higher than one month ago. Please check your spreadsheet values and try again. If you need assistance, please contact ​data@greenwichai.com or call +1.203.487.6180."
              elsif !p.date_1.nil? && dates.include?(p.date_1)
                validation = false 
                flash[:notice] = "There are problems with your data. At least one date appears more than once. Please check your spreadsheet values and try again. If you need assistance, please contact ​data@greenwichai.com or call +1.203.487.6180."
              end
              
              dates<<p.date_1
              
              if !validation 
                break
                end
                
            end
            }
          end
          
          @workbookA = Spreadsheet::ParseExcel.parse(params[:upload][:datafile].path) if !params[:upload][:datafile].nil?
          if !@workbookA.nil?
            @worksheetA = @workbookA.worksheet(0)
            @worksheetA.each { |row| 
            if !row.nil? and !row[0].nil? and !row[0].date.blank? && row[0].date.to_time.day == row[0].date.to_time.end_of_month.day and !row[1].nil? and !row[1].nil?
              p = Performance.new
              p.id_1 = @information.id_1
              p.date_1 = row[0].date.to_time.end_of_month.strftime("%Y-%m-%d") if !row[0].nil? and !row[0].date.blank?
              p.return = row[1].to_s("latin1") if !row[1].nil?
              p.fundsmanaged = row[2].to_s("latin1") if !row[2].nil?
              p.firm_aum = row[3].to_s("latin1") if !row[3].nil?
              p.gross_exposure = (!row[4].nil? and !row[4].to_s("latin1").empty?) ? row[4].to_s("latin1").to_f*100 : nil
              p.nav = row[5].to_s("latin1") if !row[5].nil?
              p.estimate = row[6].to_s("latin1").strip if !row[6].nil?
              p.lastupdated = Time.now
            
            
            
              #pf = Performance.find(:first, :conditions=>["id_1 in (?) and date_1 = ?", @of.map{|c| c.id_1},p.date_1])
              #f_firm_aum = ""
              #f_firm_aum = pf.firm_aum if !pf.nil?
              #p.firm_aum = !pcrp[5].to_s.strip.blank? ? pcrp[5] : f_firm_aum
              
              p.save 
            end
            }
          end
        else
          flash[:notice] = "Monthly Data File format incorrect. Please upload performance in XLS format (Excel 97-2003)"
        end
      end
    rescue Exception => exc
      flash[:notice] = "Errors reading the file"
    end
  
    begin
      if !params[:upload].nil? and !params[:upload][:datafile2].nil?
        if params[:upload][:datafile2].original_path.include?(".xls") && !params[:upload][:datafile2].original_path.include?(".xlsx")
          fls = params[:upload][:datafile2]
          require 'parseexcel'
          @workbookB = Spreadsheet::ParseExcel.parse(params[:upload][:datafile2].path) if !params[:upload][:datafile2].nil?
          if !@workbookB.nil?
            @worksheetB = @workbookB.worksheet(0)
            rn = 0
            @worksheetB.each { |row|
              if !row.nil?
                rn = rn + 1
                if rn > 1
                  p = DailydataDay.new
                  p.id_1 = @information.id_1
                  p.date_1 = (row[0].date.strftime("%Y-%m-%d")) if !row[0].nil? and !row[0].date.blank?
                  p.return = row[1].to_s("latin1") if !row[1].nil?
                  p.fundsmanaged = row[2].to_s("latin1") if !row[2].nil?
                  p.firm_aum = row[3].to_s("latin1") if !row[3].nil?
                  p.gross_exposure = (!row[4].nil? and !row[4].to_s("latin1").empty?) ? row[4].to_s("latin1").to_f*100 : nil
                  p.nav = row[5].to_s("latin1") if !row[5].nil?
                  p.estimate = row[6].to_s("latin1").strip if !row[6].nil?
                  #p.lastupdated = Time.now
                  p.save
                end
            end
            }
          end
        else
          flash[:notice] = "Monthly Data File format incorrect. Please upload performance in XLS format (Excel 97-2003)"
        end
      end
    rescue Exception => exc
      flash[:notice] = "Errors reading the file"
    end

    if @of.size>0
      of = @of.first
      Performance.all(:conditions=>["id_1 = ?", of.id_1]).each do |ofp|
        
        p = Performance.first(:conditions=>["date_1 = ? and id_1=?", ofp.date_1, @information.id_1])
        if p.nil?
          p = Performance.new()
          p.id_1 = @information.id_1
          p.date_1 = ofp.date_1
          
        end
        p.firm_aum = ofp.firm_aum
        p.save
      end
    end
    
    if !flash[:notice].nil? && !flash[:notice].blank? && !flash[:notice] != "error"
      redirect_to :action=>"new", :firm_id=>params[:firm_id]
    else
      mtf.save
      @information.save
      redirect_to :controller=>"my", :action=>"fund_info", :id=>@information.id
    end
  end
  
  def update
    @information = Information.find(params[:id])
    @information.update_attributes(params[:information])
    @information.save
    redirect_to :action=>"edit", :id=>@information.id
  end
  
  def delete
    @information = Information.find(params[:id])
    id_1 = @information.id_1
    @information.destroy
    @mtf = ManagerToFund.find_by_id_1(id_1)
    mi = ManagerInformation.find_by_manager_id(@mtf.manager_id)
    mi.destroy
    redirect_to "/funds"
  end
  
  def toggle_inc_calc
    @information = Information.find(params[:id])
    if @information.in_calc.to_i==0 
      @information.in_calc=1
    else
      @information.in_calc=0
    end
    @information.save
    redirect_to "/funds"
  end
  
  def edit
    @information = Information.find(params[:id])
  end

  def show
    @fund=Information.find(params[:id])
    @system=Systemcheck5.first(:conditions => ["id_1=?",@fund.id_1])
    @manager_to_fund=ManagerToFund.first(:conditions => ["fund_id=?",@fund.id_1])
    @manager=Manager.first(:conditions => ["manager_id=?",@manager_to_fund.manager_id])
    @yr1=Time.now.year
    @yr2=(Time.now - 2.year).year
    respond_to do |format|
      format.html do
       @format = "html"
       render "show", :layout => "search"
      end
      format.pdf do
       @format = "pdf"
       render :pdf          => @fund.id.to_s,
              :layout       => 'funds_pdf',
              :javascript   => 2000
      end
    end    
  end
  
  def do_edit
    @information = Information.find(params[:id])
    mtf = ManagerToFund.find(:first, :conditions=>["fund_id = ?", @information.id_1])
    mtf.destroy if !mtf.nil?
    mtf = ManagerToFund.new
    mtf.manager_id = ManagerInformation.find(params[:firm_id]).manager_id
    mtf.fund_id = @information.id_1
    mtf.datavendorid = @information.datavendorid
    mtf.save
    @manager_information = ManagerInformation.find(params[:firm_id])
    @information.f2 = @manager_information.address1
    @information.f3 = @manager_information.address2 
    @information.f4 = @manager_information.city
    @information.f5 = @manager_information.state_province
    @information.f6 = @manager_information.zip 
    @information.f7 = @manager_information.country
    @information.f9 = @manager_information.phone
    @information.f10 = @manager_information.fax 
    @information.f11 = @manager_information.email
    @information.f12 = @manager_information.contact_person
    @information.f13 = @manager_information.contact_title
    @information.f18 = @manager_information.website
    @information.f34 = @manager_information.firm_assets
    @information.f1 = @manager_information.general_partner
    @information.manager_id = params[:firm_id]
    @information.save
    
    redirect_to "/funds/edit?id="+@information.id.to_s
  end

end