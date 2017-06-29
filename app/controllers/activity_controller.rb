class ActivityController < ApplicationController
  before_filter :prepare_data, :only => :index

  def index
    @months = get_years
  end

  def update_my_fund_activity
    fund = MyFundsActivity.clicks_from(Date.today.month, Date.today.year)
    if fund.nil?
      fund = MyFundsActivity.new
      fund.month = Date.today.month
      fund.year = Date.today.year
      fund.counts = 0
    end
    fund.counts = fund.counts + 1
    fund.save
    render :nothing => true
  end

  def create_report
    report = MyReportsCreated.clicks_from(Date.today.month, Date.today.year)
    if report.nil?
      report = MyReportsCreated.new
      report.month = Date.today.month
      report.year = Date.today.year
      report.counts = 0
    end
    report.counts = report.counts + 1
    report.save
    render :nothing => true
  end

  def view_fund
    views = MyPerformaceSummaryActivity.clicks_from(Date.today.month, Date.today.year)
    if views.nil?
      views = MyPerformaceSummaryActivity.new
      views.month = Date.today.month
      views.year = Date.today.year
      views.counts = 0
    end
    views.counts = views.counts + 1
    views.save
    render :nothing => true
  end

  private

    def prepare_data
      if params[:year] and params[:month]
        year = params[:year]
        month = params[:month]
      else
        year = Date.today.year
        month = Date.today.month
      end
      @my_funds_clicks = MyFundsActivity.my_funds_from(month, year)
      @my_reports_created = MyReportsCreated.reports_created_from(month, year)
      @my_pdf_viewed = MyPerformaceSummaryActivity.pfd_viewed_from(month, year)
      @number_of_search = MySearchActivity.get_number_of_search(month, year)
      @strategies_numbers = MySearchActivity.get_numbers_of_strategies(month, year)
      @filters_popularity = MySearchFilters.get_filters_popularity(month, year)
      @filters_used = MySearchActivity.get_numbers_of_filters(month, year)
      @portfolio_sizes = PortfolioSize.get_sizes(month,year)
    end

    def get_years
      mfa = MyFundsActivity.get_years
      mrc = MyReportsCreated.get_years
      mpsa = MyPerformaceSummaryActivity.get_years
      msa = MySearchActivity.get_years
      return (mfa | mrc | mpsa | msa).sort.reverse
    end
end