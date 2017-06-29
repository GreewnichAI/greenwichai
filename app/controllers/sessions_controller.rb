# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  
#  include AuthenticatedSystem
	#after_filter :do_log
	
	def do_log
		LogEvent.new(:c=>request.parameters['controller'],:m=>request.parameters['action'], :p=>request.parameters.to_param, :user_id=>(current_user.nil? ? nil : current_user.id)).save
	end
	
  # render new.rhtml
  def new
  redirect_to "/"
  #	render :layout=>false
  end

  def create
    redirect_to "/"
=begin
    logout_keeping_session!
    user = User.authenticate(params[:login], params[:password])
    if user and user.active==1
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
    else
      note_failed_signin
      flash[:notice] = "Wrong username or password. Contact info@greenwichai.com for help."
      @login       = params[:login]
      @remember_me = params[:remember_me]
      render :action => 'new', :layout=>false
    end
=end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

  def find_pw
    user = User.first(:conditions=>["login like ? or email like ?", params[:query], params[:query]])
    if !user.nil? and !user.email.to_s.strip.blank?
      user.password = user.password_confirmation = Digest::MD5.hexdigest(rand("349283412").to_s)[0..5]
      user.save
      Emailer.deliver_message(user.email,"Greenwichai Forgot user password","Login:#{user.login}<br/>Your new password:#{user.password}")
      flash[:alert] = "A new password has been emailed to you. If you do not see it in your inbox shortly, please be sure to check spam folders. For further assistance, please contact us at +1.203.487.6180 on info@greenwichai.com"
      redirect_to "/"
    else
      redirect_to "/sessions/no_email"
    end

  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
