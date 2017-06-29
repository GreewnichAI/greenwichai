namespace :invites do
    desc "Build Queue"
    task :send => :environment do
      inv=Invite.first(:conditions=>["status like ? ", "in_queue"])
      i = 0
      while (!inv.nil? and i<20) do
        i = i + 1 
        inv.status="sent"
        
        
        @informations_full = Information.all(:conditions=>["(f11 like ? or f42 like ? or f45 like ?) and (upper(F20) not like ? and upper(F20) not like ? and upper(F20) not like ? and upper(F20) not like ?) and f51 like ?","%"+inv.email+"%","%"+inv.email+"%","%"+inv.email+"%","%DELETE%", "%WRI%","%DUPLICATE%","%DEFUNCT%", "Master List"])
        tbl="<table>"
        tbl=tbl+"<tr ><th style='text-align:left;' width='600'>Fund Name</th><th style='text-align:left;'>Last Updated</th></tr>"
        @informations_full.each do |information|
          tbl=tbl+"<tr><td>"+information.f20+"</td><td>"+(!information.lastupdated.nil? ? information.lastupdated.strftime("%Y-%m-%d") : "")+"</td></tr>"
        end 
        tbl=tbl+"</table>"
        
        inv.txt = inv.txt.gsub("<FUND_TABLE>",tbl).gsub("\n","<br/>")
        inv.save
        Emailer.deliver_invite(inv)
        inv=Invite.first(:conditions=>["status like ?", "in_queue"])
      end
    end
end
