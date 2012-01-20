class Skin < ActiveRecord::Base
  
  def self.get_skins
    return Skin.all
  end
end
