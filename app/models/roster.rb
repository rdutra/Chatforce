require "communicator"
class Roster < ActiveRecord::Base  

  belongs_to :buddy
  validates_presence_of :buddy_id

  class << self
    def for_buddy_id(buddy_id)
      Roster.where(:buddy_id => buddy_id)[0] || self.new(:buddy_id => buddy_id, :count => 0)
    end

    def subscribe
      Juggernaut.subscribe do |event, data|
        data.default = {}
        buddy_id = data["meta"]["buddy_id"]
        unless buddy_id.nil? && buddy_id.blank?
          case event
            when :subscribe
              event_subscribe(buddy_id)
            when :unsubscribe
              event_unsubscribe(buddy_id)
          end
        end
      end
    end
    
    protected
      def event_subscribe(buddy_id)
        buddy = self.for_buddy_id(buddy_id)
        buddy.increment!
      end
      
      def event_unsubscribe(buddy_id)
        buddy = self.for_buddy_id(buddy_id)
        buddy.decrement!
      end
      
  end
  
  def increment!
    self.count += 1
    if self.count <= 0
      self.count = 1
    end
    if (self.count == 1)
      buddy = Buddy.find self.buddy_id
      
      sender = self.buddy_id
      status = "Online"
      message = {:code => "status", :message => status}
      channel = buddy.org.org_id

      Communicator.send_message channel, sender, 0, message
      Buddy.set_status sender, status

      puts "user #{buddy.name} is connected"
    end
    self.save
  end
  
  def decrement!
    self.count -= 1
    if self.count  <= 0
      buddy = Buddy.find self.buddy_id
      
      sender = self.buddy_id
      status = "Offline"
      message = {:code => "status", :message => status}
      channel = buddy.org.org_id

      Communicator.send_message channel, sender, 0, message
      Buddy.set_status sender, status
      
      puts "user #{buddy.name} is disconnect"
    end
    self.save
  end
end
