class CreateBuddies < ActiveRecord::Migration
  def change
    create_table :buddies do |t|
      t.string :name
      t.string :nickname
      t.string :status

      t.timestamps
    end
  end
end
