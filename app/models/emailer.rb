class Emailer < ActionMailer::Base
  def invite(invite)
      @subject = invite.subject || "Please fill in the needed data"
      # @recipients = "ABoucher@greenwichai.com" # invite.email
      @recipients = invite.email
      #@bcc = "razvan@mosel.ro"
      @from = 'Greenwich Alternative Investments <data@greenwichai.com>'
      @sent_on = Time.now
      @body["message"] = invite.txt
      @headers = {}
   end

  def message(to,subject,message)
    @subject = subject || "Please fill in the needed data"
    @recipients = to # invite.email
    #@recipients = invite.email
    #@bcc = "razvan@mosel.ro"
    @from = 'Greenwich Alternative Investments <data@greenwichai.com>'
    sent_on = Time.now
    @body["message"] = message
    @headers = {}
  end

end
