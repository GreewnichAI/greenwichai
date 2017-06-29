class ElemOfSetsController < ApplicationController
  before_filter :login_required
  after_filter :do_log
	
	def do_log
		LogEvent.new(:c=>request.parameters['controller'],:m=>request.parameters['action'], :p=>request.parameters.to_param, :user_id=>(current_user.nil? ? nil : current_user.id)).save
	end
def index
	if params[:subelem_id].to_i>0
		@set_of_set = SetOfSet.find(:first, :conditions=>["elem_of_set_id = ?",params[:subelem_id]])
	else
		@set_of_set = SetOfSet.find(params[:set_of_set_id])
	end

	if params[:subelem_id].to_i>0
		@elem_of_set = ElemOfSet.find(params[:subelem_id])
		if @set_of_set.nil?
			@set_of_set = SetOfSet.new
			@set_of_set.elem_of_set_id = params[:subelem_id]
			@set_of_set.name = @elem_of_set.name
			@set_of_set.save
		end
	end
	
	@elem_of_sets = ElemOfSet.find(:all, :conditions=>["set_of_set_id = ?", @set_of_set.id ])
end

def new
	@elem_of_set = ElemOfSet.new
	@elem_of_set.set_of_set_id = params[:set_of_set_id]
end

def create
	@elem_of_set = ElemOfSet.new(params[:elem_of_set])
	@elem_of_set.save
=begin	
	if params[:has_subsets].to_i==1
		st = SetOfSet.new
		st.name = @elem_of_set.name
		st.has_subsets = 1
		st.elem_of_set_id = @elem_of_set.id
		st.save
	end
=end
	redirect_to :action=>:index, :set_of_set_id=>@elem_of_set.set_of_set_id
end

def edit
	@elem_of_set = ElemOfSet.find(params[:id])
	render :action=>"new"
end

def update
	@elem_of_set = ElemOfSet.find(params[:id])
	@elem_of_set.update_attributes(params[:elem_of_set])
	@elem_of_set.save
	redirect_to :action=>:index, :set_of_set_id=>@elem_of_set.set_of_set_id
end

def destroy
	@elem_of_set = ElemOfSet.find(params[:id])
	@elem_of_set.destroy
	redirect_to :action=>:index, :set_of_set_id=>@elem_of_set.set_of_set_id
end

end
