class CreateRosters < ActiveRecord::Migration
  def change
    create_table :rosters do |t|
      t.references :buddy
      t.timestamps
    end
  end
end
