class AddPostToFacebookWall < ActiveRecord::Migration
  def self.up
    add_column :photos, :post_to_facebook_wall, :string
    add_column :photos, :post_to_facebook_album, :string
  end

  def self.down
    remove_column :photos, :post_to_facebook_wall
    remove_column :photos, :post_to_facebook_album
  end
end
