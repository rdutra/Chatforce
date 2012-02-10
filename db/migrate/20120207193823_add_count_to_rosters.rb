class AddCountToRosters < ActiveRecord::Migration
  def change
    add_column :rosters, :count, :integer, :default => 0
  end
end
