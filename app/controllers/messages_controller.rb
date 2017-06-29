class MessagesController < ApplicationController
	before_filter :login_required
	def archive
		message = Message.find(params[:id])
		message.archive
		#message.archived_at = Time.now
		#message.save
		
		redirect_to :action=>"index"
	end
	
	def unarchive
		message = Message.find(params[:id])
		message.unarchive
		#message.archived_at = nil
		#message.save
		redirect_to :action=>"index"
	end
	
	
end
