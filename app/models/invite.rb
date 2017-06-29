class Invite < ActiveRecord::Base
  def self.get_uniq_key
    rnd = ""
    while rnd=="" do
      rnd = Digest::MD5.hexdigest(Time.now.to_s+rand(1000000000).to_s)[6..15]
      i = Invite.find_by_act_key(rnd)
      if !i.nil?
        rnd = ""
      end
    end
    return rnd
  end
end
