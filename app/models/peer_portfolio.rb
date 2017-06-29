class PeerPortfolio < ActiveRecord::Base
  belongs_to :user
  belongs_to :fund, :class_name => 'Information'
end
