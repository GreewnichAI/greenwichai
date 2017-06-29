class Usercheck7 < ActiveRecord::Base
  set_table_name "usercheck7"

  def update_f49(f49)
  	(1..24).each do |k|
  		self.write_attribute("c"+k.to_s, 0)
  	end
    if f49=="Long/Short Equity - Growth"
      self.c1 = 1
      self.c3 = 1
    elsif f49=="Long/Short Equity - Value"
      self.c1 = 1
      self.c2 = 1
    elsif f49=="Long/Short Equity - Opportunistic"
      self.c1 = 1
      self.c4 = 1
    elsif f49=="Short-Selling"
      self.c1 = 1
      self.c5 = 1
    elsif f49=="Equity Market Neutral"
      self.c6 = 1
      self.c7 = 1
    elsif f49=="Convertible Arbitrage"
      self.c6 = 1
      self.c12 = 1
      self.c13 = 1
    elsif f49=="Merger Arbitrage"
      self.c6 = 1
      self.c8 = 1
      self.c9 = 1
    elsif f49=="Statistical Arbitrage"
    elsif f49=="Fixed Income Arbitrage"
      self.c6 = 1
      self.c12 = 1
      self.c14 = 1
    elsif f49=="Fixed Income"
      self.c21 = 1
      self.c22 = 1
    elsif f49=="Multiple Arbitrage Strategies"
      self.c6 = 1
      self.c12 = 1
      self.c15 = 1
    elsif f49=="Distressed Securities"
    	self.c6 = 1
      self.c10 = 1
      self.c8 = 1
    elsif f49=="Multiple Event-Driven Strategies"
    	self.c6 = 1
      self.c11 = 1
      self.c8 = 1
    elsif f49=="Macro"
    	self.c16 = 1
      self.c17 = 1
    elsif f49=="Futures - Systematic"
    	self.c16 = 1
      self.c18 = 1
      self.c19 = 1
    elsif f49=="Futures - Discretionary"
    	self.c16 = 1
      self.c18 = 1
      self.c20 = 1    
    elsif f49=="Futures - Systematic and Discretionary"
     	self.c16 = 1
      self.c18 = 1
    elsif f49=="Multi-Strategy"
      self.c21 = 1
      self.c23 = 1
    elsif f49=="Fund of Funds"
    	self.c24 = 1
    end
  
    self.save
    
  end
  
  def update_f38(f38)
  	[33,34,35,38,39,40,41,42,43,44,46,47,50,51,53,54,56,57,58,60,61].each do |k|
  		self.write_attribute("c"+k.to_s, 0)
  	end
  	if f38=="Japan"
  		self.c33 = 1
  	elsif f38=="Australia"
  		self.c34 = 1
    elsif f38=="Asia-Pacific"
    	self.c35 = 1
    elsif f38=="United Kingdom"
    	self.c38 = 1
    elsif f38=="Scandinavia"
    	self.c39 = 1
    elsif f38=="Germany"
    	self.c40 = 1
    elsif f38=="Italy"
    	self.c41 = 1
    elsif f38=="France"
    	self.c42 = 1
    elsif f38=="Spain"
    	self.c43 = 1
    elsif f38=="Netherlands"
    	self.c44 = 1
    elsif f38=="Canada"
    	self.c46 = 1
    elsif f38=="United States"
    	self.c47 = 1
    elsif f38=="Eastern Europe"
    	self.c50 = 1
    elsif f38=="Russia"
    	self.c51 = 1
    elsif f38=="China"
    	self.c53 = 1
    elsif f38=="India"
    	self.c54 = 1
    elsif f38=="Argentina"
    	self.c56 = 1
    elsif f38=="Brazil"
    	self.c57 = 1
    elsif f38=="Mexico"
    	self.c58 = 1
    elsif f38=="Middle East"
    	self.c60 = 1
    elsif f38=="Africa"
			self.c61 = 1
  	end
		self.save
	end

  def update_f40(f40)
  	[31,32,36,37,45,48,49,52,55,59].each do |k|
  		self.write_attribute("c"+k.to_s, 0)
  	end
		if f40=="Global"
			self.c31 = 1
		elsif f40=="Asia"
			self.c32 = 1
		elsif f40=="Pan-European"
			self.c36 = 1
		elsif f40=="Western Europe"
			self.c37 = 1
		elsif f40=="North America"
			self.c45 = 1
		elsif f40=="Emerging Markets - Global"
			self.c48 = 1
		elsif f40=="Emerging Markets - Europe"
			self.c49 = 1
		elsif f40=="Emerging Markets - Asia"
			self.c52 = 1
		elsif f40=="Emerging Markets - Latin America"
			self.c55 = 1
		elsif f40=="Emerging Markets - Middle East and Africa"
			self.c59 = 1
		end
		self.save
	end
	
	def update_f48(f48)
		[71,78,87,92].each do |k|
  		self.write_attribute("c"+k.to_s, 0)
  	end
		if f48=="Equities"
			self.c71 = 1
		elsif f48=="Fixed Income"
			self.c78 = 1
		elsif f48=="Commodities"
			self.c87 = 1
		elsif f48=="Currencies"
			self.c92 = 1	
		end
		self.save
	end
	
	def update_f41(f41)
		[72,73,74,75,76,77,79,80,81,82,83,84,85,86,88,89,90,91].each do |k|
  		self.write_attribute("c"+k.to_s, 0)
  	end
		if f41=="Technology"
			self.c72 = 1
		elsif f41=="Infrastructure"
			self.c73 = 1
    elsif f41=="Energy"
    	self.c74 = 1
    elsif f41=="Financials"
    	self.c75 = 1
    elsif f41=="Healthcare"
    	self.c76 = 1
    elsif f41=="Real Estate"
    	self.c77 = 1
    elsif f41=="Agency"
    	self.c79 = 1
		elsif f41=="Government"
			self.c80 = 1
		elsif f41=="CS"
			self.c81 = 1
		elsif f41=="Credit - Investment Grade"
			self.c82 = 1
		elsif f41=="Credit - High Yield"
			self.c83 = 1
		elsif f41=="MBS"
			self.c84 = 1
		elsif f41=="ABS"
			self.c85 = 1
		elsif f41=="ABL"
			self.c86 = 1
		elsif f41=="Energy"
			self.c88 = 1
		elsif f41=="Agriculture"
			self.c89 = 1
		elsif f41=="Metals"
			self.c90 = 1
		elsif f41=="Financial"
			self.c91 = 1
		end
		self.save
	end

end
