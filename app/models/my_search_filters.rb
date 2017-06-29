class MySearchFilters < ActiveRecord::Base
  #before_filter :set_up_date

  def self.update_search_filters(values)
    @current_year = Date.today.year
    @current_month = Date.today.month

    search = self.find(:first, :conditions=>["YEAR(created_at) = ? and MONTH(created_at) = ?", @current_year.to_i, @current_month.to_i])
    if search.nil?
      search = self.new
      search.lrm = 0
      search.ytd = 0
      search.car = 0
      search.cr = 0
      search.md = 0
      search.sd = 0
      search.shape = 0
    end
    unless values.nil?
      search.lrm = search.lrm + (values[:lrm].nil? ? 0 : values[:lrm])
      search.ytd = search.ytd + (values[:ytd].nil? ? 0 : values[:ytd])
      search.car = search.car + (values[:car].nil? ? 0 : values[:car])
      search.cr = search.cr + (values[:cr].nil? ? 0 : values[:cr])
      search.md = search.md + (values[:md].nil? ? 0 : values[:md])
      search.sd = search.sd + (values[:sd].nil? ? 0 : values[:sd])
      search.shape = search.shape + (values[:shape].nil? ? 0 : values[:shape])
    end
    
    search.save
  end

  def self.get_filters_popularity(month, year)
    @current_year = Date.today.year
    @current_month = Date.today.month
    search = self.find(:first, :conditions=>["YEAR(created_at) = ? and MONTH(created_at) = ?", year.to_i, month.to_i])
    if search.nil?
      search = self.new
      search.lrm = 0
      search.ytd = 0
      search.car = 0
      search.cr = 0
      search.md = 0
      search.sd = 0
      search.shape = 0
    end
    if @current_year == year && @current_month == month
      search.save
    end
    return search
  end

  private
    def set_up_date
      @current_year = Date.today.year
      @current_month = Date.today.month
    end
end
