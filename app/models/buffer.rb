class Buffer < ActiveRecord::Base
  belongs_to :buddy
  
  def self.add_to_buffer data
    new_buffer = Buffer.new data
    new_buffer.save
    return new_buffer
  end
  
  def self.get_from_buffer buddy_id
    buffers = Buffer.where(:buddy_id => buddy_id).order("created_at DESC")
    return buffers
  end
  
  def self.clean_buffer buddy_id
    buffers = Buffer.where(:buddy_id => buddy_id).order("created_at DESC")
    buffers.each do |buffer|
      Buffer.delete(buffer[:id])
    end
  end
end
