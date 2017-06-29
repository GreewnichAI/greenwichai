class FirmsController < ApplicationController
  #before_filter :login_required, :except=>["index_json"]
  after_filter :do_log
	
	def do_log
		LogEvent.new(:c=>request.parameters['controller'],:m=>request.parameters['action'], :p=>request.parameters.to_param, :user_id=>(current_user.nil? ? nil : current_user.id)).save
	end
	
	def index
		
	end
	
	def index_json
  	filters = params[:filter] || []
  	cond1 = []
  	cond2 = []
  	filters.each do |k,filter_arr|
#  		if (filter_arr[:field] =~ /^g_addresses/).nil?
  				cond1 << "upper(manager_information."+filter_arr[:field]+") like ?"
#  		end

#  		if !(filter_arr[:field] =~ /^g_addresses/).nil?
#  				cond1 << "g_addresses."+filter_arr[:field].gsub("g_addresses_","")+" like ?" 
#  		end

  		cond2 << "%"+filter_arr[:data][:value].to_s.upcase+"%"
  	end
  	cond1 = cond1.join(" and ")
  	
  	cond_final = []
  	cond_final << cond1
		cond_final = cond_final + cond2
  	
  	limit = params[:limit] ? params[:start]+","+params[:limit] : ""
  	
#  	if !(params[:sort] =~ /^g_addresses/).nil?
#  		params[:sort] = "g_addresses."+params[:sort]
#  	elsif params[:sort].to_s.size>0
#  		params[:sort] = "users."+params[:sort]
#  	end
  	
  	firms = ManagerInformation.find(:all, :order=>params[:sort]+" "+params[:dir], :conditions=>cond_final, :limit=>limit)
  	hsh = {}
  	hsh[:total] = ManagerInformation.count
  	hsh[:data] = []
  	
  	firms.each do |firm|
  		
  		
  		
  		dt = {}
  		
  		dt[:general_partner] = firm.general_partner
  		dt[:address1] = firm.address1
  		dt[:phone] = firm.phone  		
  		dt[:email] = firm.email
  		dt[:contact_person] = firm.contact_person
  		fff = ""
  		firm.users.each do |fr|
  			fff = fff + "<a target='nw_"+fr.id.to_s+"' href='/users/edit/"+fr.id.to_s+"'>"+fr.full_name.to_s+"</a><br/>"
  		end
  		dt[:user_names] = fff
  		dt[:id] = firm.id
  		hsh[:data] << dt
  	end
  	
  	
  	
  	
  	render :text=>hsh.to_json
	end
	
	def new
		@manager_information = ManagerInformation.new
	end
	
	def create
		@manager_information = ManagerInformation.new(params[:manager_information])
		@manager_information.manager_id = ManagerInformation.find(:last, :order=>"manager_id").manager_id.to_i+1
		@manager_information.save
		#redirect_to :action=>"edit", :id=>@manager_information.id
		redirect_to :controller=>"funds", :action=>"new", :firm_id=>@manager_information.id
	end
	
	def edit
		@manager_information = ManagerInformation.find(params[:id])
	
		render :action=>"new"
	end

	def update
		@manager_information = ManagerInformation.find(params[:id])
		@manager_information.update_attributes(params[:manager_information])
		@manager_information.save
		redirect_to :action=>"edit", :id=>@manager_information.id
	end
	
	def assoc_user
		@manager_information = ManagerInformation.find(params[:id])

	end
	def do_assoc_user
		mtps = ManagerToProfiles.find(:all, :conditions=>["manager_id = ? and donor_id = ?", params[:manager_id], User.find(params[:user_id]).owner_id])
		mtps.each do |mtp|
			mtp.destroy
		end
		mtp = ManagerToProfiles.new
		mtp.manager_id = params[:manager_id]
		mtp.donor_id = User.find(params[:user_id]).owner_id
		mtp.save
		
		redirect_to :action=>"edit", :id=>ManagerInformation.find(:first, :conditions=>["manager_id = ?", params[:manager_id]]).id
	end
	
end
