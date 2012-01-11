class Org < ActiveRecord::Base
  has_many :Buddies, :dependent => :destroy

def self.add_org options
  new_org = Org.new({:org_id => options[:org_id]})
  new_org.save
  return new_org
end


def self.exists_org sfid
    org = Org.where(:org_id => sfid)[0]
    unless org.nil?
      return true
    else
      return false
    end
  end

def self.getOrgBySfId sfid
  org = Org.where(:org_id => sfid)[0]
  unless org.nil?
    return org
  else
    return false
  end
end    

def self.synchronize orgId
  time_range = (Time.now - 24.hour)..Time.now
  org = Org.where(:org_id => orgId , :updated_at => time_range)[0]
  unless org.nil?
    users = Buddy.where(:org_id => org["id"])
    sfusers = Users.getAll
    unless sfusers.size == users.size
      if sfusers.size > users.size
        sfusers["records"].each do |sfuser|
          unless Buddy.exists_buddy sfuser['Id']
            new_user = Buddy.new({
              :name             => sfuser['Name'],
              :nickname         => '',
              :status           => "Offline",
              :salesforce_id    => sfuser['Id'],
              :small_photo_url  => sfuser['SmallPhotoUrl'],
              :org_id           => org["id"]
            })
            new_user.save
          end
        end
      end
      if users.size > sfusers.size
        sfusers.each do |user|
          #we need to delete the users that are not in salesforce
        end
      end
    end
  end
end


end
