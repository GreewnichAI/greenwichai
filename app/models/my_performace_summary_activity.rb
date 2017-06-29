class MyPerformaceSummaryActivity < ActiveRecord::Base
  def self.get_years
    query = "SELECT DISTINCT(year) FROM my_funds_activities ORDER BY year DESC"
    years = ActiveRecord::Base.connection.execute(query)
    result = []
    years.each do |year|
      y = /\d\d\d\d/.match(year.to_s)
      result << y.to_s
    end
    result
  end
  def self.clicks_from(month, year)
    self.find(:first, :conditions=>["month = ? and year = ?", month.to_i, year.to_i])
  end
  def self.pfd_viewed_from(month, year)
    result = self.find(:first, :conditions=>["month = ? and year = ?", month.to_i, year.to_i])
    if result.nil?
      result = 0
    else
      result = result.counts
    end
    return result
  end
end
