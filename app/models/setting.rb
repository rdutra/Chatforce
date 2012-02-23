class Setting < ActiveRecord::Base
  belongs_to  :buddy, :dependent => :destroy
  
  def self.save_settings options, nickname
    unless options.empty?
      if Setting.existsSetting(options[:buddy_id])
        setting = Setting.get_settings(options[:buddy_id])
        setting.history = options[:history]
        setting.skin = options[:skin]
        #these have not yet been implemented
        setting.buddy.nickname = nickname
        setting.show_offline = (options[:show_offline] == "on")
        setting.idle_time = options[:idle_time]
        setting.msg_style = "Bubble"
        setting.use_picture = 1
      else
        setting = Setting.new(options)
      end
      setting.save
      setting.buddy.save
      return setting
    end
  end
  
  def self.get_settings buddy_id
    return Setting.where(:buddy_id => buddy_id)[0] || Setting.create(:buddy_id => buddy_id)
  end
  
  def self.existsSetting buddy_id
    settings = Setting.where(:buddy_id => buddy_id)[0]
    return !settings.nil?
  end
  
end
