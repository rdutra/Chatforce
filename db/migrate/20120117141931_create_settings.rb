class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.integer :skin
      t.integer :history

      t.timestamps
    end
  end
end
