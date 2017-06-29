# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def field_or_null(val)
    val.blank? ? "N/A" : number_with_precision(val, :precision => 2)
  end

			def select_tag2(aa,b,c,cls="len50",tip="string",sz=0, noother=0)
					c=c.to_s
					if cls.class==String
						cls1 = cls
						cls2 = ""
					else
						cls1 = cls[0]
						cls2 = cls[1]
					end
					
					
					tx = c
					other_arr = [["Other","other"]]
					other_arr = [] if noother==1
					select_arr = [["[Select]",""]]
					
					
					if tip=="percent"
						kb = []
						b.each do |k|
							parsed_value = (k.to_f/100).to_s
							kb << [k,parsed_value]
							tx = "" if parsed_value==c
							
						end
						tx = tx.to_f * 100 if tx.to_f>0
						b = kb
					
					elsif tip=="percent2"
						kb = []
						b.each do |k|
							parsed_value = k
							parsed_value = k.to_s+"%" if k.to_i.to_s==k.to_s
							kb << [parsed_value,k]
							tx = "" if k==c
						end
						b=kb
					
					elsif tip=="money"
						parsed_c = c.to_s.gsub(",","")
						kb = []
						b.each do |k|
							parsed_value = number_to_currency(k.to_i, :precision=>0).gsub("$", "")
							kb << [parsed_value,k]
							tx = "" if parsed_c==k
						end
						b = kb
						c = parsed_c
					
					
					elsif tip=="bool1"
						kb = []
						b.each do |k|
							parsed_value = "1" if k.upcase=="YES"
							parsed_value = "0" if k.upcase=="NO"
							kb << [k,parsed_value]
							tx = "" if parsed_value==c
							#other_arr = [["[Select]",""]]
							text_f_tag = ""
						end
						b = kb 
					
					else
						kb = []
						b.each do |k|
							kb << [k, k.downcase]
						end
						#c = c.downcase
						#b = kb
						tx = "" if !b.index(c).nil?
					end
				  if cls2.blank? && cls1.include?("validation-failed")
            ret_dt = select_tag(aa,options_for_select(other_arr+b+select_arr, c), :class=>"validation-failed")
          else
            ret_dt = select_tag(aa,options_for_select(other_arr+b+select_arr, c), :class=>cls2)
          end

					ret_dt = ret_dt + text_field_tag("over_"+aa,tx, :class=>cls1) if tip!="bool1"
					return ret_dt
			end



		def select_tag3(aa,b,c,cls="len50",tip="string",sz=0)
					
					if cls.class==String
						cls1 = cls
						cls2 = ""
					else
						cls1 = cls[0]
						cls2 = cls[1]
					end
					
					
					tx = c
					other_arr = [["Other","Other"]]
					select_arr = []
					
					
					if tip=="percent"
						kb = []
						b.each do |k|
							parsed_value = (k.to_f/100).to_s
							kb << [k,parsed_value]
							tx = "" if parsed_value==c
							
						end
						tx = tx.to_f * 100 if tx.to_f>0
						b = kb
					
					elsif tip=="percent2"
						kb = []
						b.each do |k|
							parsed_value = k
							parsed_value = k.to_s+"%" if k.to_i.to_s==k.to_s
							kb << [parsed_value,k]
							tx = "" if k==c
						end
						b=kb
					
					elsif tip=="money"
						parsed_c = c.to_s.gsub(",","")
						kb = []
						b.each do |k|
							parsed_value = number_to_currency(k.to_i, :precision=>0).gsub("$", "")
							kb << [parsed_value,k]
							tx = "" if parsed_c==k
						end
						b = kb
						c = parsed_c
					
					
					elsif tip=="bool1"
						kb = []
						b.each do |k|
							parsed_value = "1" if k.upcase=="YES"
							parsed_value = "0" if k.upcase=="NO"
							kb << [k,parsed_value]
							tx = "" if parsed_value==c
							other_arr = [["[Select]",""]]
							text_f_tag = ""
						end
						b = kb 
					
					else
						kb = []
						b.each do |k|
							kb << [k, k.downcase]
						end
						#c = c.downcase
						#b = kb
						tx = "" if !b.index(c).nil?
					end
					
					ret_dt = select_tag(aa,options_for_select(other_arr+b, c), :class=>cls2) 
					ret_dt = ret_dt + text_field_tag("over_"+aa,tx, :class=>cls1) if tip!="bool1"
					return ret_dt
			end

  def cus_sortable(name, cur_sort_by)
    order_by  = get_order_by(cur_sort_by, @sort_by, @order_by)
    class_str = [order_by, (cur_sort_by == @sort_by ? ' sorted' : '')].join(' ')
    link_to name, '#', :class=>class_str, 'data-sort-by'=>cur_sort_by, 'data-order-by'=>order_by
  end

  def get_lower_date(date1, date2)
    [date1.year, date2.year].min
  end

  def field_or_null(val, precision=2)
  	val.blank? ? "N/A" : number_with_precision(val, :precision => precision)
  end

  def field_or_null_with_percent(val, precision=2)
    val.blank? ? "N/A" : number_to_percentage(val, :precision => precision)
  end

  def get_order_by(cur_sort_by, sort_by, order_by)
    if cur_sort_by == sort_by
      order_by = order_by == 'desc' ? 'asc' : 'desc' 
      return order_by   
    else
      return ''
    end
  end

  def str_or_na(str)
    str.blank? ? 'N/A' : str
  end 			
end
