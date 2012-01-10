class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.string     :key
      t.integer    :sender_id
      t.integer    :receiver_id
      t.timestamps
    end
  end
end
