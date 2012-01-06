require 'test_helper'

class BuddyTest < ActiveSupport::TestCase
  
  # Use fixtures data vendors and clients
  fixtures :buddies
  
  test "change status" do
    status = "Available"
    buddy = Buddy.set_status 1, status
    assert_equal(status, buddy[:status]) 
  end
end
