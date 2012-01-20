class Buddy < ActiveRecord::Base
include HTTParty
  has_many :connection
  has_many :channel, :through => :connection
  has_many :buffer
  belongs_to :org
  has_one :session, :dependent => :destroy
  has_one :setting
  format :json
  
  STATUSES = %w{ Available Away Busy Offline } 
  
  def self.get_buddy_by_id buddy_id
    buddy = Buddy.find(buddy_id)
    return buddy
  end
  
  def self.get_all_by_org org_id
    buddies = Buddy.where(:org_id => org_id)
    return buddies
  end
  
  def self.set_status buddy_id , status
    buddy = Buddy.find(buddy_id)
    unless buddy.nil?
      if STATUSES.include? status
        buddy[:status] = status
        buddy.save
      end
    end  
    return buddy
  end
  
  def self.get_buddy_by_Sfid sf_id
    buddy = Buddy.where(:salesforce_id => sf_id)[0]
    return buddy
  end
  
  def self.exists_buddy sf_id
    buddy = Buddy.where(:salesforce_id => sf_id)[0]
    return !buddy.nil?
  end
  
  def self.add_buddy options
    new_user = Buddy.new(options)
    new_user.save
    return new_user
  end
  
  def self.get_buddies_by_org org_id
    buddies = Buddy.where(:org_id => org_id)
    return buddies
  end
end
