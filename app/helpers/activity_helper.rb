module ActivityHelper
  def generate_years_for_form(years)
    result = ""
    current_year = Date.today.year
    years.each do |year|
      if current_year == year
        result << "<option selected='selected'>#{year}</option>"
      else
        result << "<option>#{year}</option>"
      end
    end
    return result
  end

  def generate_months_for_form()
    months = ["January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"]

    result = ""
    months.each_with_index do |month, i|
      result << "<option value='#{i+1}'>#{month}</option>"
    end
    return result
  end
end