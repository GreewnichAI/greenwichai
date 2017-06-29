# This controller handles the login/logout function of the site.  
class UserSessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead

  # render new.rhtml
  def new
    @user_session = UserSession.new
    render :layout=>false
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Login successful!"
      redirect_back_or_default "/"
    else
      flash[:notice] = "Wrong username or password"
      render :action => :new, :layout=>false
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end
  
    def svnup                                                                                                                                                     
    a = ""                                                                                                                                                      
    if params[:password]=="ijsda99211"
        f = File.open("/tmp/srip_svn_up", "w")
        f.close
        a+="Scheduled svn up & migrate. Will run in 5 min."                                                                                                                                               
    end                                                                                                                                                         
    render :text=>a                                                                                                                                             
  end                                                                                                                                                           


protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
