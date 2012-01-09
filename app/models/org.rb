class Org < ActiveRecord::Base

has_many :Buddies

def self.exists_org sfid
    org = Org.where(:org_id => sfid)
    unless org.empty?
      return true
    else
      return false
    end
  end

def self.getOrgBySfId sfid
  org = Org.where(:org_id => sfid)
  unless org.empty?
      return org
    else
      return false
    end
end

end
