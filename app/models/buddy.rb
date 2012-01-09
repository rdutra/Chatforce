class Buddy < ActiveRecord::Base
include HTTParty

  belongs_to :org ,:foreign_key => 'org_id'
  format :json
  
  STATUSES = %w{ Available Away Busy Offline } 
  
  def get_buddy_by_id buddy_id
    buddy = Buddy.where(:id => buddy_id)[0]
    return buddy
  end
  
  def self.get_all
    buddies = Buddy.all
    return buddies
  end
  
  def self.set_status buddy_id , status
    buddy = Buddy.where(:id => buddy_id)[0]  
    unless buddy.nil?
      if STATUSES.include? status
        buddy[:status] = status
        buddy.save
      end
    end  
    return buddy
  end
  
  def self.get_buddy_by_Sfid sfid
    buddy = Buddy.where(:salesforce_id => sfid)
    unless buddy.empty?
      return buddy
    else
      return false
    end
  end
  
  def self.exists_buddy sfid
    buddy = Buddy.where(:salesforce_id => sfid)
    unless buddy.empty?
      return true
    else
      return false
    end
  end
  
end
