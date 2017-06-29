class DbCleanupController < ApplicationController
  before_filter :login_required
  after_filter :do_log
	
	def do_log
		LogEvent.new(:c=>request.parameters['controller'],:m=>request.parameters['action'], :p=>request.parameters.to_param, :user_id=>(current_user.nil? ? nil : current_user.id)).save
	end
	
	def t1_search
		render :layout=>false
	end
	
	def t1_do
		id_1 = params[:id_1]
		Information.find(:all, :conditions=>["id_1 = ?", id_1]).each do |ob| ob.destroy; end
		
		Systeminformation1.find(:all, :conditions=>["id_1 = ?", id_1]).each do |ob| ob.destroy; end
		Systeminformation2.find(:all, :conditions=>["id_1 = ?", id_1]).each do |ob| ob.destroy; end
		Systeminformation3.find(:all, :conditions=>["id_1 = ?", id_1]).each do |ob| ob.destroy; end
		Systeminformation4.find(:all, :conditions=>["id_1 = ?", id_1]).each do |ob| ob.destroy; end
		Systeminformation5.find(:all, :conditions=>["id_1 = ?", id_1]).each do |ob| ob.destroy; end
		Systeminformation6.find(:all, :conditions=>["id_1 = ?", id_1]).each do |ob| ob.destroy; end
		
		Systemcheck1.find(:all, :conditions=>["id_1 = ?", id_1]).each do |ob| ob.destroy; end
		Systemcheck2.find(:all, :conditions=>["id_1 = ?", id_1]).each do |ob| ob.destroy; end
		Systemcheck3.find(:all, :conditions=>["id_1 = ?", id_1]).each do |ob| ob.destroy; end
		Systemcheck4.find(:all, :conditions=>["id_1 = ?", id_1]).each do |ob| ob.destroy; end
		Systemcheck5.find(:all, :conditions=>["id_1 = ?", id_1]).each do |ob| ob.destroy; end
		Systemcheck6.find(:all, :conditions=>["id_1 = ?", id_1]).each do |ob| ob.destroy; end
			
		Userinformation1.find(:all, :conditions=>["id_1 = ?", id_1]).each do |ob| ob.destroy; end
		Userinformation2.find(:all, :conditions=>["id_1 = ?", id_1]).each do |ob| ob.destroy; end
		Userinformation3.find(:all, :conditions=>["id_1 = ?", id_1]).each do |ob| ob.destroy; end
		Userinformation4.find(:all, :conditions=>["id_1 = ?", id_1]).each do |ob| ob.destroy; end
		Userinformation5.find(:all, :conditions=>["id_1 = ?", id_1]).each do |ob| ob.destroy; end
		Userinformation6.find(:all, :conditions=>["id_1 = ?", id_1]).each do |ob| ob.destroy; end
				
		Usercheck1.find(:all, :conditions=>["id_1 = ?", id_1]).each do |ob| ob.destroy; end
		Usercheck2.find(:all, :conditions=>["id_1 = ?", id_1]).each do |ob| ob.destroy; end
		Usercheck3.find(:all, :conditions=>["id_1 = ?", id_1]).each do |ob| ob.destroy; end
		Usercheck4.find(:all, :conditions=>["id_1 = ?", id_1]).each do |ob| ob.destroy; end
		Usercheck5.find(:all, :conditions=>["id_1 = ?", id_1]).each do |ob| ob.destroy; end
		Usercheck6.find(:all, :conditions=>["id_1 = ?", id_1]).each do |ob| ob.destroy; end
		
		Systemmemo1.find(:all, :conditions=>["id_1 = ?", id_1]).each do |ob| ob.destroy; end
		Usermemo1.find(:all, :conditions=>["id_1 = ?", id_1]).each do |ob| ob.destroy; end
			
		redirect_to :action=>"t1"
	end
  
  def t2
      abc = ActiveRecord::Base.connection
      Information.all(:conditions=>["f51 like ?", "DELETE"]).each do |i|
          abc.execute("delete from performance where id_1 = #{i.id_1}")
          (1..4).each do |n|
            abc.execute("delete from systeminformation#{n} where id_1 = #{i.id_1}")
            abc.execute("delete from systemcheck#{n} where id_1 = #{i.id_1}")
            abc.execute("delete from userinformation#{n} where id_1 = #{i.id_1}")
            
          end
          abc.execute("delete from systemmemo1 where id_1 = #{i.id_1}")
          abc.execute("delete from usermemo1 where id_1 = #{i.id_1}")
          
          
          i.destroy
        end
        redirect_to "/db_cleanup/tools"
  end
  
end
