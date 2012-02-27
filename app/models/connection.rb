class Connection < ActiveRecord::Base
  belongs_to :buddy
  belongs_to :channel
  
  def self.connect_buddy buddy_id, channel_id
    conn = Connection.where(:buddy_id => buddy_id, :channel_id => channel_id)[0]
    puts conn.inspect
    if conn.nil?
      bud = Buddy.get_buddy_by_id buddy_id
      chan = Channel.get_channel_by_id channel_id
      unless bud.nil? || chan.nil?
        conn = Connection.new({
          :buddy_id => buddy_id,
          :channel_id => channel_id
        })
        conn.save
      end
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
  
  def self.verify_org org_id
    exists_org = true
    org_by_id =  Org.where(:org_id => org_id)
    if org_by_id[0].nil?
      exists_org = false
    end
    return exists_org
  end

end
