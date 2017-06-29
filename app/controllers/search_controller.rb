class SearchController < ApplicationController
  before_filter :login_required

  layout 'search'

  def index
    @funds=Information.all(:group => 'f49', :order=> 'f49')
    @strategies = ["All Strategies"]
    @funds.each do |f|
        !f.f49.nil? ? @strategies << f.f49 : ""
    end
    @funds=Information.all(:group => 'f40', :order => 'f40')
    @regions = ["All Regions"]
    @funds.each do |f|
      !f.f40.nil? ? @regions << f.f40 : ""
    end
    @minmax_stats = Marshal.load(Settings.minmax_stats)
  end

  def src
    #year = Date.today.year
    #month = Date.today.month
    #msf = MySearchFilters.get_filters_popularity(month, year)
    values = {}
    if params[:lmr_hidden].to_i == 1
      #msf.lrm = msf.lrm + 1
      values[:lrm] = 1
    end
    if params[:f_ytd_hidden].to_i == 1
      #msf.ytd = msf.ytd + 1
      values[:ytd] = 1
    end
    if params[:car_12_hidden].to_i == 1 || params[:car_24_hidden].to_i == 1 || params[:car_36_hidden].to_i == 1 || params[:car_48_hidden].to_i == 1 || params[:car_inception_hidden].to_i == 1
      #msf.car = msf.car + 1
      values[:car] = 1
    end  
    if params[:cr_12_hidden].to_i == 1 || params[:cr_24_hidden].to_i == 1 || params[:cr_36_hidden].to_i == 1 || params[:cr_48_hidden].to_i == 1
      #msf.cr = msf.cr + 1
      values[:cr] = 1
    end
    if params[:md_12_hidden].to_i == 1 || params[:md_24_hidden].to_i == 1 || params[:md_36_hidden].to_i == 1 || params[:md_48_hidden].to_i == 1 || params[:md_inception_hidden].to_i == 1
      #msf.md = msf.md + 1
      values[:md] = 1
    end
    if params[:sd_12_hidden].to_i == 1 || params[:sd_24_hidden].to_i == 1 || params[:sd_36_hidden].to_i == 1 || params[:sd_48_hidden].to_i == 1 || params[:sd_inception_hidden].to_i == 1
      #msf.sd = msf.sd + 1
      values[:sd] = 1
    end
    if params[:sharpe_12_hidden].to_i == 1 || params[:sharpe_24_hidden].to_i == 1 || params[:sharpe_36_hidden].to_i == 1 || params[:sharpe_48_hidden].to_i == 1 || params[:sharpe_inception_hidden].to_i == 1
      #msf.shape = msf.shape + 1
      values[:shape] = 1
    end
    
    save_search(params[:strategy], values)

     cond1 = []
     cond2 = []
     cond1 << "f51 = ?"
     cond2 << "Master List"
     cond1 << "(general_partner like ? collate utf8_general_ci or f20 like ?  collate utf8_general_ci)"
     cond2 << "%" + params[:name].gsub(" ","%").gsub("-","%") + "%"
     cond2 << "%" + params[:name].gsub(" ","%").gsub("-","%") + "%"
     if params[:strategy]!='All Strategies'
       cond1 << " (f15 = ? or f37 = ? or f39 = ? or f49 = ? )"
       cond2 << params[:strategy]
       cond2 << params[:strategy]
       cond2 << params[:strategy]
       cond2 << params[:strategy]
     end

     if params[:is_active].to_i==1
       cond1 << " is_active = ?"
       cond2 << "1"
     end

     if params[:region]!='All Regions'
       cond1 << " f40 = ? "
       cond2 << params[:region]
     end
     @fields = []
      if params[:src_max]
       params[:src_max].each do |i,j|
         if params[i+"_hidden"].to_i==1
           cond1 << "("+i+" between ? and ?)"
           @fields << i
           cond2 << params[:src_min][i]
           cond2 << params[:src_max][i]
         end
       end
      end

     conditions = [cond1.join(" and ")] + cond2
     @direction = params[:direction].to_s.blank? ? "ASC" : params[:direction]
     @order = params[:order].to_s.blank? ? "f20" : params[:order]
     
     
     @fund_count = Information.count(:joins=>:manager, :conditions=> conditions)
     @page_count = (@fund_count.to_f / PER_PAGE).ceil
     @page_count = 1 if @page_count<1
     @page = params[:page].to_i
     @page = @page_count if @page>@page_count
     @page = 1 if @page.to_i<1
     @funds = Information.all(:joins=>:manager, :conditions=> conditions, :limit => ((@page-1) * PER_PAGE).to_s+","+PER_PAGE.to_s, :order=>@order+" "+@direction)

     render :layout=>false
  end

  def save_search(strategy, values)
    MySearchFilters.update_search_filters(values)
    msa = MySearchActivity.new
    msa.strategy_name = strategy.to_s
    msa.number_filters_used = values.count
    msa.save
    

  end

  def get_params(params)
    values = {}
    if params[:lmr_hidden] == 1
      values[:lmr] = 1
    end
    if params[:f_ytd_hidden] == 1
      values[:ytd] = 1
    end
    if params[:car_12_hidden] == 1 || params[:car_24_hidden] == 1 || params[:car_36_hidden] == 1 || params[:car_48_hidden] == 1 || params[:car_inception_hidden] == 1
      values[:car] = 1
    end  
    if params[:cr_12_hidden] == 1 || params[:cr_24_hidden] == 1 || params[:cr_36_hidden] == 1 || params[:cr_48_hidden] == 1
      values[:cr] = 1
    end
    if params[:md_12_hidden] == 1 || params[:md_24_hidden] == 1 || params[:md_36_hidden] == 1 || params[:md_48_hidden] == 1 || params[:md_inception_hidden] == 1
      values[:md] = 1
    end
    if params[:sd_12_hidden] == 1 || params[:sd_24_hidden] == 1 || params[:sd_36_hidden] == 1 || params[:sd_48_hidden] == 1 || params[:sd_inception_hidden] == 1
      values[:sd] = 1
    end
    if params[:sharpe_12_hidden] == 1 || params[:sharpe_24_hidden] == 1 || params[:sharpe_36_hidden] == 1 || params[:sharpe_48_hidden] == 1 || params[:sharpe_inception_hidden] == 1
      values[:shape] = 1
    end
    return values
  end
end
