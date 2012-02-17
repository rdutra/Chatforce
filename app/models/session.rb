#require 'ruby-debug' ; Debugger.start
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
  
  def self.get_session_by_buddy_id buddy_id
    buddy_session = Session.where(:buddy_id => buddy_id)[0]
    return buddy_session
  end
  
  def self.refresh session_id, options
    updated_session = Session.update(
          session_id,
          :buddy_id => options[:buddy_id],
          :expires_at => options[:expires_at],
          :token => options[:token],
          :instance_url => options[:instance_url],
          :name => options[:name],
          :salt => options[:salt]
        )
    return updated_session
  end
  
  def self.refresh_salt session_id, hash
    updated_session = Session.find(session_id)
    updated_session['salt'] = hash
    updated_session.save
    return updated_session
  end
  
end
