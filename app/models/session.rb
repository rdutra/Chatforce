class Session < ActiveRecord::Base
  belongs_to :buddy
  
  def self.get_session_by_id session_id
    buddy_session = Session.where(:id => session_id)[0]
    return buddy_session
  end
  
  
  def self.create_session options
    new_session = Session.new(options)
    new_session.save
    return new_session
  end
  
  def self.refresh session_id
    refreshed_session = Session.update(session_id, :expires_at => Time.now + 5.hours)
    return refreshed_session
  end
  
  def self.get_session_by_buddy_id buddy_id
    buddy_session = Session.where(:buddy_id => buddy_id)[0]
    return buddy_session
  end
end