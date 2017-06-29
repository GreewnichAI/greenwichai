class InvitesController < ApplicationController
  def index
    @invite = Invite.find_by_act_key(params[:k])
    if @invite.nil?
      render :text=>"<script>alert('No such invite');document.location.href='/';</script>"
    else
      if @invite.status=="sent"
        @invite.status="accessed"
        @invite.save
      end
      
      
      
      @informations_full = Information.all(:conditions=>["(f11 like ? or f42 like ? or f45 like ?) and (upper(F20) not like ? and upper(F20) not like ? and upper(F20) not like ? and upper(F20) not like ?) and f51 like ?","%"+@invite.email+"%","%"+@invite.email+"%","%"+@invite.email+"%","%DELETE%", "%WRI%","%DUPLICATE%","%DEFUNCT%", "Master List"])
      @informations = []  
      @informations_full.each do |information|
          ui4 = information.userinformation4
          if information.f51 == "Master List"
            @informations << information 
          end
 
      end
      if @informations.size>0 and @informations.size<4
        redirect_to :action=>:step2, :k=>params[:k]
      end    
      
    end
    
  end
  
  def step2
    @invite = Invite.find_by_act_key(params[:k])
    @informations = []
    if @invite.nil?
      render :text=>"<script>alert('No such invite');document.location.href='/';</script>"
    else
      if !params[:infos].nil?
        params[:infos].each do |k,unu|
          @informations << Information.find(k)
        end
      else
        @informations_full = Information.all(:conditions=>["(f11 like ? or f42 like ? or f45 like ?) and (upper(F20) not like ? and upper(F20) not like ? and upper(F20) not like ? and upper(F20) not like ?) and f51 like ?","%"+@invite.email+"%","%"+@invite.email+"%","%"+@invite.email+"%","%DELETE%", "%WRI%","%DUPLICATE%","%DEFUNCT%", "Master List"])
        @informations = []  
        @informations_full.each do |information|
          ui4 = information.userinformation4
          if ui4.f3.to_s!="Yes" and ui4.f4.to_s!="Yes"
            @informations << information 
          end
        end
      end
    end
    
    pas = Performance.all(:conditions=>["id_1 = ? and date_1>?", @informations.first.id_1, Time.now-4.month]).map{|c| {c.date_1.strftime("%Y-%m-%d")=>(c.firm_aum.blank? ? "" : c.firm_aum.gsub(",","").to_f/1000000)}}
    @firm_aums = {}
    pas.each do |p|
      @firm_aums = @firm_aums.deep_merge(p)
    end

  end
  
  def do_save
    @invite = Invite.find_by_act_key(params[:k])
    params[:d_return].each do |fund_id,arr|
      i = Information.find(fund_id)
      arr.each do |dt,vl|
        ddt = dt[0..3]+"-"+dt[4..5]+"-"+dt[6..7]
        p = Performance.first(:conditions=>["id_1 = ? and date_1 like ?", i.id_1, ddt+"%"])
        if p.nil?
          p = Performance.new
          p.date_1 = ddt
          p.id_1 = i.id_1
        end
        
        if p.return.to_s.strip=="" or p.return_ds.to_s.strip==""
          p.return_ds = "Email Invitation"
          p.return_ut = Time.now
        end
        if p.aum_ds.to_s.strip=="" or p.aum_ds.to_s.strip==""
          p.aum_ds = "Email Invitation"
          p.aum_ut = Time.now
        end
        
        p.return = params[:d_return][fund_id.to_s][dt].blank? ? "" : params[:d_return][fund_id.to_s][dt].to_f / 100
        p.fundsmanaged = number_to_currency(params[:d_fundaum][fund_id.to_s][dt].to_f*1000000, :precision=>0).gsub("$","")
        p.nav = params[:d_nav_shares][fund_id.to_s][dt]
        p.gross_exposure = params[:d_gross_exposure][fund_id.to_s][dt]
        p.estimate = params[:d_estimate][fund_id.to_s][dt].to_s == "0" ? 0 : 1
        p.save
      end
      i.lastupdated=Time.now
      @system1 = i.systeminformation1
      
      i.save
    params[:firm_aum].each do |dt,val|
	    vl = number_to_currency(val.to_f*1000000, :separator=>".", :precision=>0).to_s.gsub("$","")  
      i.set_firm_aum(dt.to_s,vl)
    end

    end

    @invite.status="saved"
    @invite.save
    @user_session = UserSession.new
    redirect_to :action=>"thank_you", :k=>params[:k]
  end
  
  def register
    @invite = Invite.find_by_act_key(params[:k])
    @user = User.new
    @user.active = 0
    @user.email = @invite.email
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


      
      mtf = nil
      mtf = ManagerToFund.first(:conditions=>["fund_id = ?", @i.id_1]) if !@i.nil?
      if !mtf.nil?
        mtp = ManagerToProfiles.new
        mtp.manager_id = mtf.manager_id
        mtp.donor_id = @user.owner_id
        mtp.save
      end 
    
      Message.to_admins("<a target='nwwin' href='/users/"+@user.id.to_s+"/edit'>"+@user.login.to_s+"</a> registered and is inactive.",1)
      flash[:alert] = "Your user profile has been created. A member of our team will contact you to confirm information and activate registration within 24 hours."
      redirect_to "/"
    else
      render :action=>:register      
    end
    
  end
end
