class Portfolio < ActiveRecord::Base
  belongs_to :user

  has_many :fund_portfolios, :dependent => :destroy
  has_many :funds, :through => :fund_portfolios 

  def self.fund_group_order(group)
    expected_order =  {
                        "Market Neutral Group" => 1,
                        "Long-Short Equity Group" => 2,
                        "Directional Trading Group" => 3,
                        "Specialty Strategies Group" => 4,
                        "Fund of Funds Group" => 5
                      }

    num = expected_order[group] || 6
    return num
  end   
end
