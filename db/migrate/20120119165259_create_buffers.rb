class CreateBuffers < ActiveRecord::Migration
  def change
    create_table :buffers do |t|
      t.integer :buddy_id
      t.string :channel
      t.string :message
      t.timestamps
    end
  end
end
