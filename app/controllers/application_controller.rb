# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
#	include AuthenticatedSystem
	include ActionView::Helpers::NumberHelper
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
	
	#def date_tpl
		#return "to_date(?, 'dd.mm.YYYY')"
		#return "?"
#	end
#	def date_fmt
		#return "%d.%m.%Y"
#		return "%Y-%m%-%d"
#	end
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  helper_method :current_user_session, :current_user
  filter_parameter_logging :password, :password_confirmation

  def app_logger msg
    log = Logger.new('log/logfile.log')
    log.level = Logger::WARN
    log.warn(msg)
  end

  private
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.record
    end

    def require_user
      unless current_user
        store_location
#        flash[:notice] = "You must be logged in to access this page"
        redirect_to "/user_session/new"
        return false
      end
    end
    def login_required
        require_user
    end
    def current_efg_user
      current_user
    end

    def require_no_user
      if current_user
        store_location
        flash[:notice] = "You must be logged out to access this page"
        redirect_to account_url
        return false
      end
    end

    def store_location
      session[:return_to] = request.request_uri
    end

    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

end
