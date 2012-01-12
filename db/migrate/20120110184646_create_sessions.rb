class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.integer :buddy_id
      t.date :expires_at
      t.string :token
      t.string :instance_url
      t.references :buddy
      t.timestamps
    end
  end
end
