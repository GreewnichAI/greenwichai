require 'digest/sha1'

class User < ActiveRecord::Base
#  include Authentication
#  include Authentication::ByPassword
#  include Authentication::ByCookieToken
  acts_as_authentic do |c|
      c.act_like_restful_authentication = true
  end

  validates_length_of :company_name, :within=>1..40, :on=>:create
#  validates_length_of       :login,    :within => 2..40, :message=> "Email is too short (minimum is 2 characters)"
#  validates_uniqueness_of   :login
  validates_length_of   :first_name, :within => 2..256
  validates_length_of   :last_name, :within => 2..256
  validates_length_of   :phone_number, :within => 10..256
  
  #validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message
  has_one :g_address, :primary_key=>"owner_id", :foreign_key=>"owner_id", :class_name=>"GAddress"

  has_attached_file :att1
  has_attached_file :att2
  has_attached_file :att3
  has_attached_file :att4
  has_many :peer_portfolios
  has_many :portfolio_informations, :through => :peer_portfolios, :foreign_key=>:fund_id, :source => :fund

  #validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  #validates_length_of       :name,     :maximum => 100

  #validates_presence_of     :email
  #validates_length_of       :email,    :within => 6..100 #r@a.wk
  #validates_uniqueness_of   :email
  #validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
#  attr_accessible :login, :email, :name, :password, :password_confirmation, :manager_id, :first_name, :last_name, :tip, :phone_number, :active, :att1, :att2, :att3, :att4, :company_name, :first_name, :last_name



  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
=begin
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_by_login(login.downcase) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end
=end

	def manager_id
		mtp = ManagerToProfiles.find(:first, :conditions=>["donor_id = ?", self.owner_id])
		mtp.nil? ? nil : mtp.manager_id
	end
	
	def firm
		manager_id = self.manager_id
		manager_id.nil? ? ManagerInformation.new : ManagerInformation.find(:first, :conditions=>["manager_id=?",manager_id.to_i])
	end
	
	def fund_names
		cond_def = " and F20 not like  '% DELETE %'  and F20 not like '% WRI %'  and F20 not like '%DEFUNCT%'"
		fund_names = ""
		rez=ActiveRecord::Base.connection.execute( "SELECT i.f20 FROM manager_to_fund mtf JOIN information i ON mtf.fund_id=i.id_1 WHERE mtf.manager_id="+self.manager_id.to_i.to_s+cond_def)
		while row = rez.fetch_row do
				fund_names = fund_names + "<br/>" + row[0]
		end
		
		return fund_names
	end
	
	def funds
		cond_def = " and F20 not like  '% DELETE %'  and F20 not like '% WRI %'  and F20 not like '%DEFUNCT%'"
		funds = {}
		rez=ActiveRecord::Base.connection.execute( "SELECT i.* FROM manager_to_fund mtf JOIN information i ON mtf.fund_id=i.id_1 WHERE mtf.manager_id="+self.manager_id.to_i.to_s+cond_def)
		while row = rez.fetch_hash do
				funds[row['id']] = row
		end
		return funds
	end

	def full_name
		return self.first_name.to_s+" "+self.last_name.to_s + " ["+self.login.to_s+"]"
	end
  protected
    


end
