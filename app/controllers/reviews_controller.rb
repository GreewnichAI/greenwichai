class ReviewsController < ApplicationController
  
  before_filter :require_user
	
  def index
    @informations = []
    @universes    = []
    ManagerToFund.find(:all, :conditions=>["MANAGER_ID = ?", current_user.manager_id]).each do |mtf|
	#Information.find(:all, :conditions=>["ID_1 = ? and upper(F20) not like ? and upper(F20) not like ? and upper(F20) not like ? and upper(F20) not like ? and F51 like ?", mtf.fund_id, "%DELETE%", "%WRI%","%DUPLICATE%","%DEFUNCT%", "Master List"]).each do |information|
        Information.find(:all, :conditions=>["ID_1 = ? and F51 = ?", mtf.fund_id, "Master List"]).each do |information|
        @informations << information # if information.f51 == "Master List"
			end	
		end
		if @informations.count > 0
		  @universes = @informations.first.universe_selector
		  @p_bms     = Information.primary_benchmark
		  @s_bms     = Information.secondary_benchmark
		end
  end

  def get_universes
    @information = Information.find_by_id(params[:fund_id])
    @universes = @information ? @information.universe_selector : ["All Funds"]
    render :json => {:universes => @universes}.to_json
  end
  
  def initiate
    @review         = params[:review]
    @information    = Information.find_by_id(@review[:fund_name])
    @performance    = Performance.first(:conditions => ["performance.return is not null and id_1 = ?", @information.id_1], :order => "date_1 desc")
    @universe       = @review[:universe]
    @p_bm           = Information.find_by_id_1(@review[:p_bm])
    @s_bm           = Information.find_by_id_1(@review[:s_bm])
    @chartData      = @information.evaluate_report_data(@review)

    respond_to do |format|
      format.html do
        @format = "html"
      end
      format.pdf do
       @format = "pdf"
       render :pdf          => @information.id.to_s,
              :layout       => 'review_pdf'
      end
    end

  end
end
