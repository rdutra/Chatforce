class AddOrgIdToBuddies < ActiveRecord::Migration
  def change
    add_column :buddies, :org_id, :integer
  end
end
