class Buddy < ActiveRecord::Base
include HTTParty

  format :json
  
  def get_buddy_by_id buddy_id
    buddy = Buddy.where(:id => buddy_id)[0]
    return buddy
  end
  
  def add_buddy buddy
    new_buddy = Buddy.new
    new_buddy.name = buddy[:name]
    new_buddy.nickname = buddy[:nickname]
    new_buddy.status = buddy[:status]
    new_buddy.save
  end
  
end
