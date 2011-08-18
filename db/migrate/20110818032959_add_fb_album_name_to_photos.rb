class AddFbAlbumNameToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :fb_album_name, :string
  end

  def self.down
    remove_column :photos, :fb_album_name
  end
end
