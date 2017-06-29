class RegisterController < ApplicationController
  def index
    @user = User.new
    @user.active = 0 
  end
  
  def user_save
    @user = User.new(params[:user])
    @user.login=@user.email
    if @user.save
      @user.owner_id = 100000 + @user.id
      @user.tip="member"
      @user.save
      @informations_full = Information.all(:conditions=>["(f11 like ? or f42 like ? or f45 like ?) and (upper(F20) not like ? and upper(F20) not like ? and upper(F20) not like ? and upper(F20) not like ?)","%"+@user.email+"%","%"+@user.email+"%","%"+@user.email+"%","%DELETE%", "%WRI%","%DUPLICATE%","%DEFUNCT%"])
      @i = @informations_full.first


      if 1==2
          mtf = nil
          mtf = ManagerToFund.first(:conditions=>["fund_id = ?", @i.id_1]) if !@i.nil?
          if !mtf.nil?
            mtp = ManagerToProfiles.new
            mtp.manager_id = mtf.manager_id
            mtp.donor_id = @user.owner_id
            mtp.save
          else
            mi = ManagerInformation.new
            mi.general_partner = @user.company_name
            mi.manager_id = ManagerInformation.maximum(:manager_id)+1
            mi.save
            mtp = ManagerToProfiles.new
            mtp.manager_id = mi.manager_id
            mtp.donor_id = @user.owner_id
            mtp.save
          end
      end
    
      Message.to_admins("<a target='nwwin' href='/users/"+@user.id.to_s+"/edit'>"+@user.login.to_s+"</a> registered and is inactive.",1)
      flash[:alert] = "Your user profile has been created. A member of our team will contact you to confirm information and activate registration within 24 hours."
      redirect_to "/"
    else
      render :action=>:index      
    end
    
  end
end
