class Message < ActiveRecord::Base

	def self.to_admins(msg,group=0)
		require 'digest/md5'
		gr = Digest::MD5.hexdigest((rand()*Time.now.to_f).to_s) if group==1
		User.all(:conditions=>["tip=?", "admin"]).each do |u|
			m=Message.new
			m.user_id = u.id
			m.msg = msg
			m.gr = gr if group==1
			m.from = "Admin"
			m.save
		end
	end
	
	def archive
		self.archived_at = Time.now
		self.save
		if !self.gr.nil?
			Message.find(:all, :conditions=>["archived_at is null and gr = ?", self.gr]).each do |msg|
				msg.archived_at = Time.now
				msg.save
			end
		end
	end
	
	def unarchive
		self.archived_at = nil
		self.save
		if !self.gr.nil?
			Message.find(:all, :conditions=>["archived_at is not null and gr = ?", self.gr]).each do |msg|
				msg.archived_at = nil
				msg.save
			end
		end
	end
end
