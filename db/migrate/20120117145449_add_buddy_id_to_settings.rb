class AddBuddyIdToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :buddy_id, :integer
  end
end
