class Setting < ActiveRecord::Base
  belongs_to  :Buddies, :dependent => :destroy
  
end
