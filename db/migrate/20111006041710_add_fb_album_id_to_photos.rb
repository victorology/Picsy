class AddFbAlbumIdToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :fb_album_id, :string
  end

  def self.down
    remove_column :photos, :fb_album_id
  end
end
