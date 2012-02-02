require 'supermodel'
class Roster < SuperModel::Base
  include SuperModel::Redis::Model
  include SuperModel::Timestamp::Model

  attributes :count

  belongs_to :buddy
  validates_presence_of   :buddy_id
  
  indexes :buddy_id  
  
  class << self
    def for_buddy(buddy)
      buddy_ids = buddy.channels.buddy_ids
      buddy_ids.map {|id| find_by_buddy_id(id) }.compact
    end
    
    def subscribe
      Juggernaut.subscribe do |event, data|
        data.default = {}
        buddy_id = data["meta"]["buddy_id"]
        next unless buddy_id
                
        case event
        when :subscribe
          event_subscribe(buddy_id)
        when :unsubscribe
          event_unsubscribe(buddy_id)
        end
      end
    end
    
    protected
      def event_subscribe(buddy_id)
        buddy = find_by_buddy_id(buddy_id) || self.new(:buddy_id => buddy_id)
        buddy.increment!
      end
      
      def event_unsubscribe(buddy_id)
        buddy = find_by_buddy_id(userbuddy_id_id)
        buddy && user.decrement!
      end
  end
  
  def count
    read_attribute(:count) || 0
  end
  
  def increment!
    self.count += 1
    save!
  end
  
  def decrement!
    self.count -= 1
    self.count > 0 ? save! : destroy
  end
  
  def observer_clients
    buddy.channels.buddy_ids
  end
  
  
end
