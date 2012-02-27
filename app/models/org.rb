class Org < ActiveRecord::Base
  has_many :buddy, :dependent => :destroy

  def self.add_org options
    unless options.empty?
      if Org.exists_org options[:org_id]
        new_org = Org.get_org_by_sfid options[:org_id]
        #no need to update anything since there is only the one field
      else
        new_org = Org.new({:org_id => options[:org_id]})
      end
      new_org.save
      return new_org
    end
  end
  
  
  def self.exists_org sfid

      org = Org.where(:org_id => sfid)[0]
      unless org.nil?
        puts "true"
        return true
      else
        puts "false"
        return false
      end
  end
  
  def self.insert_org org_id_p
    new_org = Org.new({:org_id => org_id_p})
    new_org.save
    return new_org
  end
  
  def self.get_org_by_id orgid
    return Org.where(:id => orgid)[0]
  end
  
  def self.get_org_by_sfid sfid
    org = Org.where(:org_id => sfid)[0]
    return org
  end
  
  def self.has_installed_package instance, token
    #cobject = Users.pingCustomObject instance, token
    #begin
      #if cobject[0]["errorCode"] == "INVALID_TYPE"
        #return false
      #end
    #rescue
      return true
    #end
  end
  
  def self.synchronize orgId, instance, token
    
    time_range = (Time.now - 24.hours)..Time.now
    org = Org.where(:org_id => orgId , :updated_at => time_range)[0]
    unless org.nil?
      users = Buddy.where(:org_id => org["id"])
      sfusers = Users.getAll instance, token
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
            #we need to delete the users that are no longer in salesforce
          end
        end
      end
    end
  end
  
  def self.synchronize_simple org_id, instance, token
    buddy_data = Users.getMe instance, token
    current_org = Org.get_org_by_sfid org_id
    unless Buddy.exists_buddy buddy_data['id']
      options = {
        :name             => buddy_data["name"],
        :nickname         => '',
        :status           => "Available",
        :salesforce_id    => buddy_data["id"],
        :small_photo_url  => buddy_data['photo']['smallPhotoUrl'],
        :org_id           => current_org["id"]
      }
      buddy = Buddy.add_buddy options
     else
        name = buddy_data["name"]
        bud = Buddy.get_buddy_by_Sfid buddy_data['id']
        bud.name = name
        bud.small_photo_url = buddy_data['photo']['smallPhotoUrl']
        bud.save
     end
  end


end
