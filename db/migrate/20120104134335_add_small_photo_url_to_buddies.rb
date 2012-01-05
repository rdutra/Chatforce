class AddSmallPhotoUrlToBuddies < ActiveRecord::Migration
  def change
    add_column :buddies, :small_photo_url, :string
  end
end
