class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.string     :key
      t.string     :mod
      t.timestamps
    end
  end
end
