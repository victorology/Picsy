class AddFbWallUrlToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :fb_wall_url, :string
  end

  def self.down
    remove_column :photos, :fb_wall_url
  end
end
