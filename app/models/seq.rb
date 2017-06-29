class Seq < ActiveRecord::Base

def self.get_one(vr)
	s = Seq.find(:first, :conditions=>["vr like ?", vr])
	if s.nil?
		s = Seq.new
		s.vr = vr
		s.vl = 0
	end
	s.vl = s.vl + 1
	s.save
	s.vl
end

end
