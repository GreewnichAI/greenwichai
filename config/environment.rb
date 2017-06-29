# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
ENV['GEM_PATH'] = '/home/ec2-user/.gems:/usr/lib64/ruby/gems/1.8'
RAILS_GEM_VERSION = '2.3.14' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

if Gem::VERSION >= "1.3.6"
  module Rails
      class GemDependency
            def requirement
                    r = super
                    (r == Gem::Requirement.default) ? nil : r
            end
      end
  end
end


RAILS_ENV="development"
PER_PAGE = 20
CRITERIAS = [
["lmr" , "Last Month Return"],
["f_ytd" , "YTD Return"],

["car_12" , "Annualized Return - Last 12 Months"],
["car_24" , "Annualized Return - Last 24 Months"],
["car_36" , "Annualized Return - Last 36 Months"],
["car_48" , "Annualized Return - Last 48 Months"],
["car_inception" , "Annualized Return - Since Inception"],

["cr_12" , "Cumulative Return - Last 12 Months"],
["cr_24" , "Cumulative Return - Last 24 Months"],
["cr_36" , "Cumulative Return - Last 36 Months"],
["cr_48" , "Cumulative Return - Last 48 Months"],
["cr_inception" , "Cumulative Return - Since Inception"],

["md_12" , "Maximum Drawdown - Last 12 Months"],
["md_24" , "Maximum Drawdown - Last 24 Months"],
["md_36" , "Maximum Drawdown - Last 36 Months"],
["md_48" , "Maximum Drawdown - Last 48 Months"],
["md_inception" , "Maximum Drawdown - Since Inception"],

["sd_12" , "Standard Deviation - Last 12 Months"],
["sd_24" , "Standard Deviation - Last 24 Months"],
["sd_36" , "Standard Deviation - Last 36 Months"],
["sd_48" , "Standard Deviation - Last 48 Months"],
["sd_inception" , "Standard Deviation - Since Inception"],

["sharpe_12" , "Sharpe - Last 12 Months"],
["sharpe_24" , "Sharpe - Last 24 Months"],
["sharpe_36" , "Sharpe - Last 36 Months"],
["sharpe_48" , "Sharpe - Last 48 Months"],
["sharpe_inception" , "Sharpe - Since Inception"]

]
Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem 'rails-settings', :lib => 'settings'
  config.gem 'parseexcel'
  config.gem 'paperclip', :version=>"2.3.11"
  config.gem 'authlogic', :version=>"2.1.6"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end


ActionMailer::Base.default_content_type = "text/html"
ActionMailer::Base.default_charset = "utf-8"
#Paperclip.options[:command_path] = "C:\Program Files\ImageMagick-6.7.0-Q8"

#ActionMailer::Base.delivery_method = :sendmail


#ActionMailer::Base.smtp_settings = {
#    :address => "193.231.173.109",
#    :port => "25",
#    :domain => "greenwichai.com"
#}

ActionMailer::Base.delivery_method = :sendmail
