class MainController < ApplicationController
	before_filter :login_required
	after_filter :do_log
	
	def do_log
	  
		LogEvent.new(:c=>request.parameters['controller'],:m=>request.parameters['action'], :p=>request.parameters.to_param, :user_id=>(current_user.nil? ? nil : current_user.id)).save
	end	
	
	def index
    current_user.accessed_at = Time.now
    current_user.save if (Time.now - current_user.accessed_at)>1.hour
		redirect_to "/main/search"
	end
	
	def search
		
	end
	

	def tab1
		limit_items = params[:limit]||50
		limit_items = limit_items.to_i - 1
		span_period = params[:span_period] || "month"
		q = "select F21 from information where id_1="+params[:id]
		rez = ActiveRecord::Base.connection.execute(q)
		rw = rez.fetch_hash
		@inception_date = rw['F21'].to_time
		
		
		if !params[:ds].nil?
			@date2 = params[:ds]["from_date(1i)"]+"-"+params[:ds]["from_date(2i)"]+"-"+params[:ds]["from_date(3i)"]
			@date2 = @date2.to_time
			@date2 = Time.now if @date2>Time.now
		else
			@date2 = Time.now
		end
		@date1 = @date2
		@date1 = @date1 - (limit_items).to_i.months if (span_period=="month")
		@date1 = @date1 - (limit_items).to_i.weeks if (span_period=="week")
		@date1 = @date1 - (limit_items).to_i.days if (span_period=="day")
		
		@date1 = @inception_date if @date1<@inception_date 
		
		@dts=[]
		b=@date1
		a=@date2
		table_name = "performance"
		
		if span_period=="week"
		
			first_friday = a-(2+a.wday).days if a.wday<5
			first_friday = a-(a.wday-5).days if a.wday>4
			first_friday = a-2.days if a.wday==0
			first_friday = first_friday + 1.week
			next_friday = first_friday
			@dts << next_friday if next_friday>@inception_date
			while (next_friday = next_friday - 7.days) > b-1.second do
				@dts << next_friday
			end
			table_name = "dailydata"
		end
		
		if span_period=="month"
			eom = a.end_of_month
			@dts << eom if eom>@inception_date
			while ( (eom = (eom - 1.month).end_of_month) > (b-1.second)) do 
				@dts << eom
			end
		end
		
		if span_period=="day"
			first_day = a
			@dts << first_day if first_day>@inception_date
			while ( first_day = first_day - 1.day ) > b-1.second do
				@dts << first_day 
			end
			table_name = "dailydata_day"
		end
		
		
		
		q="select * from "+table_name+" where id_1="+params[:id].to_s+" and date_1 between to_date('"+@dts.last.strftime("%d.%m.%Y")+"','dd.mm.YYYY') and to_date('"+@dts.first.strftime("%d.%m.%Y")+"','dd.mm.YYYY') order by date_1 desc"
		rez = ActiveRecord::Base.connection.execute(q)
		@dt_vals = {}
		while(row=rez.fetch_hash) do
			@dt_vals[row['DATE_1'].to_time.strftime("%Y%m%d")] = row
		end
	end

	def tab1_save
		table_name="performance"
		table_name="dailydata" if params[:span_period]=="week"
		table_name="dailydata_day" if params[:span_period]=="day"
		
		a = ""
		fund_id = params[:id]
		params[:d_return].each do |indice,vl|
			d_return = params[:d_return][indice].to_f/100
			d_fundaum = number_to_currency(params[:d_fundaum][indice].to_f*1000000, :precision=>0).gsub("$","")
			d_nav_shares = params[:d_nav_shares][indice]
			d_estimate = params[:d_estimate][indice]=="no" ? 0 : 1
			q = "select * from "+table_name+" where id_1="+fund_id.to_s+" and date_1=to_date('"+indice+"','YYmmdd')"
			rez = ActiveRecord::Base.connection.execute(q)
			row = rez.fetch_hash
					q_u = "update "+table_name+" set RETURN='"+d_return.to_s+"', FUNDSMANAGED='"+d_fundaum.to_s+"', NAV='"+d_nav_shares.to_s+"', ESTIMATE='"+d_estimate.to_s+"' where id_1="+fund_id.to_s+" and date_1=to_date('"+indice+"','YYmmdd')"
					call_rez = ActiveRecord::Base.connection.execute(q_u)
					if call_rez==0
						q_u = "insert into "+table_name+"(ID_1, DATE_1, RETURN, FUNDSMANAGED, NAV, ESTIMATE) values("+fund_id.to_s+",to_date('"+indice+"','YYmmdd'),'"+d_return.to_s+"','"+d_fundaum.to_s+"','"+d_nav_shares.to_s+"','"+d_estimate.to_s+"')"
						ActiveRecord::Base.connection.execute(q_u)
					end
					a = a + q_u+"<br/>"
			
		end
		ActiveRecord::Base.connection.execute("commit")
		redirect_to "/main/tab1?id="+fund_id.to_s+"&sv=1&span_period="+params[:span_period]
		#render :text=>a
	end
	
	def get_fundname(fund_id)
		q = "Select F20 from Information Where ID_1="+fund_id.to_s
		rez = ActiveRecord::Base.connection.execute(q)
		row = rez.fetch_hash
		row['F20']
	end
	
	def get_manager_id(fund_id)
		q = "select MANAGER_ID from MANAGER_TO_FUND where FUND_ID="+fund_id.to_s
		rez = ActiveRecord::Base.connection.execute(q)
		row = rez.fetch_hash
		row['MANAGER_ID']
	end	
	
	def get_vendor_id(fund_id)
		q = "Select DataVendorID from information where ID_1 ="+fund_id.to_s
		rez = ActiveRecord::Base.connection.execute(q)
		row = rez.fetch_hash
		row['DataVendorID']
	end
	
	def get_fund_information(fund_id)
		q = "select * from Information where ID_1="+fund_id
		rez = ActiveRecord::Base.connection.execute(q)
		row = rez.fetch_hash
		row
	end
	
	def tab2
		@manager_id = get_manager_id(params[:id])
		@fund_information = get_fund_information(params[:id])
	end
=begin
	def tab2
		limit_items = params[:limit]||50
		limit_items = limit_items.to_i - 1
		span = params[:span] || "month"
			
		q = "select F21 from information where id_1="+params[:selected_fund]
		rez = ActiveRecord::Base.connection.execute(q)
		rw = rez.fetch_hash
		@inception_date = rw['F21']
		if !params[:ds].nil? and !params[:ds][:from_date].nil?
			@from_date = params[:ds][:from_date]
		else
			@from_date = Time.now
		end
		@to_date = Time.now
		@to_date = @to_date - (limit_items).to_i.months if (span=="month")
		@to_date = @to_date - (limit_items).to_i.weeks if (span=="week")
		@to_date = @to_date - (limit_items).to_i.days if (span=="day")
		
		@dts=[]
		b=@to_date
		a=@from_date
		if span=="week"
		
			first_friday = a-(2+a.wday).days if a.wday<5
			first_friday = a-(a.wday-5).days if a.wday>4
			first_friday = a-2.days if a.wday==0
			first_friday = first_friday + 1.week
			next_friday = first_friday
			@dts << next_friday
			while (next_friday = next_friday - 7.days) > b-1.second do
				@dts << next_friday
			end

		end
		if span=="month"
			eom = a.end_of_month
			first_friday = eom-(2+eom.wday).days if eom.wday<5
			first_friday = eom-(eom.wday-5).days if eom.wday>4
			first_friday = eom-2.days if eom.wday==0
			next_friday = first_friday
			@dts << next_friday
			while (( eom = (next_friday = next_friday - 1.month).end_of_month ) > b-1.second) do
				first_friday = eom-(2+eom.wday).days if eom.wday<5
				first_friday = eom-(eom.wday-5).days if eom.wday>4
				first_friday = eom-2.days if eom.wday==0
				@dts << first_friday
			end
		end
		if span=="day"
			first_day = a
			@dts << first_day
			while ( first_day = first_day - 1.day ) > b-1.second do
				@dts << first_day
			end
		end
	end
=end
end
