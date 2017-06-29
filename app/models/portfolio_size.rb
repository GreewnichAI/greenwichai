class PortfolioSize < ActiveRecord::Base
  def self.get_sizes(month, year)

    if (month.to_i - 1) == 0
      prev_month = 12
      prev_year = year.to_i - 1
    else
      prev_month = month.to_i - 1
      prev_year = year
    end
    
    ps = self.find(:first, :conditions=>["YEAR(created_at) = ? and MONTH(created_at) = ?", year.to_i, month.to_i])
    ps_prev = self.find(:first, :conditions=>["YEAR(created_at) = ? and MONTH(created_at) = ?", prev_year.to_i, prev_month.to_i])
    if ps.nil?
      if ps_prev.nil? 
        ps = self.new
        ps.fund_0 = 0
        ps.fund_1 = 0
        ps.fund_2 = 0
        ps.fund_3 = 0
        ps.fund_4 = 0
        ps.fund_5 = 0
        ps.fund_6 = 0
        ps.fund_7 = 0
        ps.fund_8 = 0
        ps.fund_9 = 0
        ps.fund_10 = 0
      else
        ps = ps_prev
      end
    end
    return ps
  end

  def self.change(portfolio_count, incr)
    current_year = Date.today.year
    current_month = Date.today.month

    if (current_month - 1) == 0
      prev_month = 12
      prev_year = Date.today.year - 1
    else
      prev_month = Date.today.month - 1
      prev_year = current_year
    end

    ps = self.find(:first, :conditions=>["YEAR(created_at) = ? and MONTH(created_at) = ?", current_year.to_i, current_month.to_i])
    ps_prev = self.find(:first, :conditions=>["YEAR(created_at) = ? and MONTH(created_at) = ?", prev_year.to_i, prev_month.to_i])
    if ps.nil?
      if ps_prev.nil? 
        ps = self.new
        ps.fund_0 = 0
        ps.fund_1 = 0
        ps.fund_2 = 0
        ps.fund_3 = 0
        ps.fund_4 = 0
        ps.fund_5 = 0
        ps.fund_6 = 0
        ps.fund_7 = 0
        ps.fund_8 = 0
        ps.fund_9 = 0
        ps.fund_10 = 0
      else
        ps = self.new
        ps.fund_0 = ps_prev.fund_0
        ps.fund_1 = ps_prev.fund_1
        ps.fund_2 = ps_prev.fund_2
        ps.fund_3 = ps_prev.fund_3
        ps.fund_4 = ps_prev.fund_4
        ps.fund_5 = ps_prev.fund_5
        ps.fund_6 = ps_prev.fund_6
        ps.fund_7 = ps_prev.fund_7
        ps.fund_8 = ps_prev.fund_8
        ps.fund_9 = ps_prev.fund_9
        ps.fund_10 = ps_prev.fund_10
      end
    end

    if incr
      case portfolio_count
      when 0
        ps.fund_0 = ps.fund_0 - 1
        ps.fund_1 = ps.fund_1 + 1
      when 1
        ps.fund_1 = ps.fund_1 - 1
        ps.fund_2 = ps.fund_2 + 1
      when 2
        ps.fund_2 = ps.fund_2 - 1
        ps.fund_3 = ps.fund_3 + 1
      when 3
        ps.fund_3 = ps.fund_3 - 1
        ps.fund_4 = ps.fund_4 + 1
      when 4
        ps.fund_4 = ps.fund_4 - 1
        ps.fund_5 = ps.fund_5 + 1
      when 5
        ps.fund_5 = ps.fund_5 - 1
        ps.fund_6 = ps.fund_6 + 1
      when 6
        ps.fund_6 = ps.fund_6 - 1
        ps.fund_7 = ps.fund_7 + 1
      when 7
        ps.fund_7 = ps.fund_7 - 1
        ps.fund_8 = ps.fund_8 + 1
      when 8
        ps.fund_8 = ps.fund_8 - 1
        ps.fund_9 = ps.fund_9 + 1
      when 9
        ps.fund_9 = ps.fund_9 - 1
        ps.fund_10 = ps.fund_10 + 1
      end
    else
      case portfolio_count
      when 1
        ps.fund_0 = ps.fund_0 + 1
        ps.fund_1 = ps.fund_1 - 1
      when 2
        ps.fund_1 = ps.fund_1 + 1
        ps.fund_2 = ps.fund_2 - 1
      when 3
        ps.fund_2 = ps.fund_2 + 1
        ps.fund_3 = ps.fund_3 - 1
      when 4
        ps.fund_3 = ps.fund_3 + 1
        ps.fund_4 = ps.fund_4 - 1
      when 5
        ps.fund_4 = ps.fund_4 + 1
        ps.fund_5 = ps.fund_5 - 1
      when 6
        ps.fund_5 = ps.fund_5 + 1
        ps.fund_6 = ps.fund_6 - 1
      when 7
        ps.fund_6 = ps.fund_6 + 1
        ps.fund_7 = ps.fund_7 - 1
      when 8
        ps.fund_7 = ps.fund_7 + 1
        ps.fund_8 = ps.fund_8 - 1
      when 9
        ps.fund_8 = ps.fund_8 + 1
        ps.fund_9 = ps.fund_9 - 1
      when 10
        ps.fund_9 = ps.fund_9 + 1
        ps.fund_10 = ps.fund_10 - 1
      end
    end
    ps.save
  end

end
