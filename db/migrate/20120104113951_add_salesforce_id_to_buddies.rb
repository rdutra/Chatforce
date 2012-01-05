class AddSalesforceIdToBuddies < ActiveRecord::Migration
  def change
    add_column :buddies, :salesforce_id, :string
  end
end
