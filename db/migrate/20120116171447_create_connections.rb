class CreateConnections < ActiveRecord::Migration
  def change
    create_table :connections do |t|
      t.integer :buddy_id
      t.integer :channel_id
      t.timestamps
    end
  end
end
