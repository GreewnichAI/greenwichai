class PortfolioController < ApplicationController
  before_filter :login_required
  before_filter :setup

  def create
    portfolio_count = current_user.peer_portfolios.count
    unless portfolio_count >= 10
      if current_user.peer_portfolios.find_by_fund_id(params[:id])
        @message = "Fund already added."
      else
        if current_user.peer_portfolios.create(:fund_id => @fund.id)
          PortfolioSize.change(portfolio_count, true)
          @message = "Fund successfully added."
        else
          @message = "Oops! There was an issue. Try again."
        end
      end
    else
      @message = "Only 10 funds are allowed in your portfolio."
    end 
    render 'create.js.erb', :layout => false   
  end

  def destroy
    portfolio_count = current_user.peer_portfolios.count
    @pfund = current_user.peer_portfolios.find_by_fund_id(params[:id])
    if @pfund
      if @pfund.destroy
        @is_success = true
        PortfolioSize.change(portfolio_count, false)
        @message = "Fund successfully removed."
      else
        @is_success = false
        @message = "Oops! There was an issue. Try again."
      end      
    else
      @message = "Fund not found."
    end

    render 'destroy.js.erb', :layout => false   
  end

  private

    def setup
      @fund = Information.find_by_id(params[:id])
      return @message = "Fund not found." unless @fund
    end
end
