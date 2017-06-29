class MySearchActivity < ActiveRecord::Base
  def self.get_years
    query = "SELECT DISTINCT(YEAR(created_at)) FROM my_search_activities"
    years = ActiveRecord::Base.connection.execute(query)
    result = []
    years.each do |year|
      y = /\d\d\d\d/.match(year.to_s)
      result << y.to_s
    end
    result
  end
  def self.get_number_of_search(month, year)
    result = self.find(:all, :conditions=>["YEAR(created_at) = ? and MONTH(created_at) = ?", year.to_i, month.to_i])
    if result.nil?
      result = 0
    else
      result = result.count
    end
    return result
  end

  def self.get_numbers_of_filters(month, year)
    query = "SELECT number_filters_used, COUNT(number_filters_used) FROM my_search_activities WHERE YEAR(created_at) = '#{year}' and MONTH(created_at) = '#{month}' GROUP BY number_filters_used"
    strategies = ActiveRecord::Base.connection.execute(query)
    return strategies
  end

  def self.get_numbers_of_strategies(month, year)
    query = "SELECT strategy_name, COUNT(number_filters_used) FROM my_search_activities WHERE YEAR(created_at) = '#{year}' and MONTH(created_at) = '#{month}' GROUP BY strategy_name"
    strategies = ActiveRecord::Base.connection.execute(query)
    return strategies
  end
end
