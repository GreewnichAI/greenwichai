class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  #include AuthenticatedSystem
	#before_filter :login_required, :except=>["index_json"]
	after_filter :do_log
	
	def do_log
		LogEvent.new(:c=>request.parameters['controller'],:m=>request.parameters['action'], :p=>request.parameters.to_param, :user_id=>(current_user.nil? ? nil : current_user.id)).save
	end  
	def index
	  	
	end

  # render new.rhtml
  def new
    @user = User.new
    render :action=>"edit"
  end
 
  def create
  	 
    @user = User.new(params[:user])
    @user.owner_id = Seq.get_one("owner_id")
    #@user.active = 1
    
    
    if !@user.save
    	render :text=>"There were errors: <hr/><br/>"+ @user.errors.full_messages.join("<br/>")
    else 
      ga = GAddress.new
      ga.owner_id=@user.owner_id
      ga.addr_id=0
      ga.save    
    flash[:notice] = "Saved"
    	redirect_to :action=>"edit", :id=>@user.id
  	end
  end
  
  def change_firm
  	@user = User.find(params[:id])
	end
  
  def search_firm
  	mis = ManagerInformation.find(:all, :conditions=>["upper(general_partner) like ?", "%"+params[:name].upcase+"%"], :limit=>100)
  	ret_text = ""
  	mis.each do |mi|
  		ret_text = ret_text + "<a href='/users/do_change_firm/"+params[:id].to_s+"?mi_id="+mi.id.to_s+"'>"+mi.general_partner+"</a>"+ "<br/>"
  	end
  	render :text=>ret_text
	end
	def do_change_firm
		@user = User.find(params[:id])
		mi = ManagerInformation.find(params[:mi_id])
		
		ManagerToProfiles.find(:all, :conditions=>["donor_id = ?", @user.owner_id], :limit=>2).each do |mt| mt.destroy; end
		
		mtp = ManagerToProfiles.new
		mtp.manager_id = mi.manager_id
		mtp.donor_id = @user.owner_id
		mtp.save
		#@user.owner_id = mtp.donor_id
		#@user.save
		redirect_to :action=>"edit", :id=>@user.id
	end
	
  def index_json
  	

  
  	filters = params[:filter] || []
  	cond1 = []
  	cond2 = []
  	filters.each do |k,filter_arr|
  		if (filter_arr[:field] =~ /^g_addresses/).nil?
  				cond1 << "users."+filter_arr[:field]+" like ?"
  		end
  		if !(filter_arr[:field] =~ /^g_addresses/).nil?
  				cond1 << "g_addresses."+filter_arr[:field].gsub("g_addresses_","")+" like ?" 
  		end
  		cond2 << "%"+filter_arr[:data][:value]+"%"
  	end
  	cond1 = cond1.join(" and ")
  	
  	cond_final = []
  	cond_final << cond1
		cond_final = cond_final + cond2
  	
  	limit = params[:limit] ? params[:start]+","+params[:limit] : ""
  	
  	if !(params[:sort] =~ /^g_addresses/).nil?
  		params[:sort] = "g_addresses."+(params[:sort].gsub("g_addresses_",""))
  	elsif params[:sort].to_s.size>0
  		params[:sort] = "users."+params[:sort]
  	end
  	
  	users = User.find(:all, :include=>"g_address", :order=>params[:sort]+" "+params[:dir], :conditions=>cond_final, :limit=>limit)
  	hsh = {}
  	hsh[:total] = User.count
  	hsh[:data] = []
  	
  	users.each do |user|
  		
  		
  		fund_names = ""
  		emails = []
			firm = user.firm
  		dt = {}
  		
  		dt[:first_name] = user.first_name
  		dt[:last_name] = user.last_name
  		
  		if !user.manager_id.nil? and !firm.nil?
	  		dt[:fund_names] = user.fund_names
	  		dt[:firm_name] = firm.general_partner
	  		dt[:firm_phone] = firm.phone
	  		dt[:firm_email] = firm.email
  		end
  		#dt[:g_addresses_email] = user.g_address.nil? ? "" : user.g_address.email
      dt[:g_addresses_email] = user.email.to_s.blank? ? (user.g_address.nil? ? "" : user.g_address.email) : user.email
  		#dt[:g_addresses_phone] = user.g_address.nil? ? "" : user.g_address.phone
      dt[:g_addresses_phone] = user.phone_number.to_s.blank? ? (user.g_address.nil? ? "" : user.g_address.phone) : user.phone_number
      g_addr = user.g_address
      if !g_addr.nil?
        if g_addr.email.to_s.blank? 
          g_addr.email = user.email          
        end          
        if g_addr.phone.to_s.blank? 
          g_addr.phone = user.phone_number          
        end          
        g_addr.save
      end
  		dt[:login] = user.login
  		dt[:active] = user.active
  		dt[:id] = user.id
  		hsh[:data] << dt
  	end
  	
  	
  	
  	
  	render :text=>hsh.to_json
	end
	
	def edit
  		@user = User.find(params[:id])
  end

  def update
  	@user = User.find(params[:id])
    old_active = @user.active
    if @user.update_attributes(params[:user])
    new_active = @user.active
    
    if new_active!=old_active and new_active.to_i==1
      Emailer.deliver_message(@user.email,"Greenwich Database Account Activated","
Welcome to the Greenwich Database! Your account has been activated. You may now log in to GreenwichOnline, our manager reporting portal, at <a href='http://data.greenwichai.com'>http://data.greenwichai.com.</a>
Please note that your username is your email address which you registered with.<br><br/>

<strong>Entering Your Funds</strong><br/>
We recommend that you log in when you have a moment and begin entering your funds by clicking \"Add New Fund\" at the top of the page. This will take you through our new fund entry wizard. For each fund, you will be asked to enter the fund name and inception date, and upload historical performance and offering documentation. After saving those details, you will be able to confirm performance information and enter full fund details. Once the full fund profile has been completed with all required information, your free listing will be activated.<br/><br/>

<strong>Monthly Updates</strong><br/>
To assist you in maintaining up-to-date performance, you will receive a reminder via email each month with a link directly to the Greenwich Instant Update Page, where you can enter returns and AUM for all of the funds which you have listed with us in one step. You may also update performance and any other fund details by logging in to <a href='http://data.greenwichai.com'>GreenwichOnline</a> at any time.<br/><br/>

If you have any questions, please do not hesitate to call or email us.<br/>        <br/>
Kind regards,                                                             <br/><br/>
The Greenwich Data Team<br/>
GREENWICH ALTERNATIVE INVESTMENTS<br/>
4 High Ridge Park<br/>
Stamford, CT 06905<br/>
t +1.203.487.6180<br/>
f +1.203.487.6188<br/>
data@greenwichai.com<br/>
www.greenwichai.com<br/>

")
    end
    
    flash[:notice] = "Saved"
    redirect_to :action=>"edit", :id=>@user.id
    else
      render :action=>:edit
    end
    
	end

  def toggle_enable
  	@user = User.find(params[:id])
  	if @user.active.to_i==1
  		@user.active = 0
  	else 
  		@user.active = 1
  	end
  	if @user.save
      
    if @user.active==1
      Emailer.deliver_message(@user.email,"[Greenwichai] Account Activated","Welcome to the Greenwich Database! Your registration for GreenwichOnline, our manager reporting portal, has been activated. You may now access your fund listings, add new funds, edit fund profiles, or enter updated performance at any time. <br/><br/>To log in, go to http://data.greenwichai.com. Please note that your login is your email address which you registered with.<br/><br/>If you have any questions, please contact Allison Boucher at +1.203.487.6180.")
=begin      
    Emailer.deliver_message(@user.email, "Confirmation Email", "
Dear " + @user.full_name + ",<br/>
<br/>
Thank you for registering at GreenwichOnline! Your account has been activated. To update performance and access full profiles of your funds, please log in at http://data.greenwichai.com, using the login ID listed below.<br/>
<br/>
Login: "+ @user.login + "<br/>
<br/>
If you have any questions or problems, please do not hesitate to contact us at +1.203.487.6180 or support@greenwichai.com. <br/> 
    ")
=end    
  end
  render :text=>"<script type='text/javascript'>grid.store.reload();alert('Done');</script>"  
      
    else
      render :text=>"<script type='text/javascript'>alert('"+@user.errors.to_a.join("\\n")+"');</script>"
    end
    
    
  	#redirect_to "/users"
	end
	
	def search
		@users = User.find(:all, :conditions=>["login like ?", "%"+params[:user][:login]+"%"])
		@manager_id = params[:manager_id]
		render :action=>params[:view_name], :layout=>false
	end

end
