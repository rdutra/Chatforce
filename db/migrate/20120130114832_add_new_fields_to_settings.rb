class AddNewFieldsToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :idle_time, :integer, :default => 10
    add_column :settings, :msg_style, :string
    add_column :settings, :use_picture, :integer
  end
  
  
end
