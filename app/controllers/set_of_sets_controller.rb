class SetOfSetsController < ApplicationController
	before_filter :login_required
	after_filter :do_log
	
	def do_log
		LogEvent.new(:c=>request.parameters['controller'],:m=>request.parameters['action'], :p=>request.parameters.to_param, :user_id=>(current_user.nil? ? nil : current_user.id)).save
	end

def index
	@set_of_sets = SetOfSet.find(:all, :conditions=>["elem_of_set_id is null"])
end

def new
	@set_of_set = SetOfSet.new
end

def create
	@set_of_set = SetOfSet.new(params[:set_of_set])
	@set_of_set.save
	redirect_to :action=>:index
end

def edit
	@set_of_set = SetOfSet.find(params[:id])
	render :action=>"new"
end

def update
	@set_of_set = SetOfSet.find(params[:id])
	@set_of_set.update_attributes(params[:set_of_set])
	@set_of_set.save
	redirect_to :action=>:index
end

def destroy
	@set_of_set = SetOfSet.find(params[:id])
	@set_of_set.destroy
	redirect_to :action=>:index
end

end
