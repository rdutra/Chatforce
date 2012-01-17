class Connection < ActiveRecord::Base
  belongs_to :buddy
  belongs_to :channel
  
  def self.connect_buddy buddy_id, channel_id
    conn = Connection.where(:buddy_id => buddy_id, :channel_id => channel_id)[0]
    if conn.nil?
      conn = Connection.new({
        :buddy_id => buddy_id,
        :channel_id => channel_id
      })
      conn.save
    end
    return conn
  end
  
  def self.disconnect_buddy buddy_id, channel_id
    conn = Connection.where(:buddy_id => buddy_id, :channel_id => channel_id)[0]
    unless conn.nil?
      conn.destroy()
    end
    return conn
  end
end
