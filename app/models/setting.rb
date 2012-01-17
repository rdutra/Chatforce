class Setting < ActiveRecord::Base
  belongs_to  :buddy, :dependent => :destroy
  
end
