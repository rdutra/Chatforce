class AddStatusMesageAndShowOfflineContactsToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :show_offline, :boolean, :default => false
  end
end
