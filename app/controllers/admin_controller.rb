class AdminController < ApplicationController
  before_filter :login_required
  before_filter :admin_required
  after_filter :do_log
  
  def admin_required
    redirect_to "/my" if current_user.tip != "admin"
  end
	
	def do_log
		LogEvent.new(:c=>request.parameters['controller'],:m=>request.parameters['action'], :p=>request.parameters.to_param, :user_id=>(current_user.nil? ? nil : current_user.id)).save
	end
	def index
	end
	def generate_queue
	  f=File.open("invite_template.txt", "w")
	  f.puts(params[:msg])
	  f.close
	  emails = []
	  names = {}
	  params[:funds].split("\n").each do |fund_name|
      i = Information.find_by_f20(fund_name.strip)
      if !i.nil?
        reg = /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i
        emails = emails + i.f11.to_s.scan(reg).uniq
        emails = emails + i.f42.to_s.scan(reg).uniq
        emails = emails + i.f45.to_s.scan(reg).uniq
        names[i.f11.to_s] = i.f12.to_s if i.f11.to_s.size>0
        names[i.f42.to_s] = i.f43.to_s if i.f42.to_s.size>0
        names[i.f45.to_s] = i.f46.to_s if i.f45.to_s.size>0
        
      end
	  end
	  emails = emails.uniq
	  emails.each do |email|
	     i = Invite.new
	     i.email = email
	     i.act_key = Invite.get_uniq_key
	     i.status="in_queue"
	     i.subject = params[:subject].to_s
	     i.link_name = params[:link_name].to_s
	     i.txt = params[:msg].to_s.gsub("<EMAIL_LINK>","<a href='http://data.greenwichai.com/invites?k="+i.act_key.to_s+"'>"+i.link_name.to_s+"</a>").gsub("<CONTACT>", names[i.email].to_s)
	     i.save 
	  end
	  flash[:alert] = "Sent "+emails.size.to_s+" invitation emails"
	  redirect_to :action=>"generate_invites"
	end
	
	
end
