class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.string     :channel_id
      t.integer    :sender_id
      t.integer    :receiver_id
      t.timestamps
    end
  end
end
