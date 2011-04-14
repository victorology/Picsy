class AddFacebookUrlPhoto < ActiveRecord::Migration
  def self.up
    add_column :photos, :fb_original_url, :string
    add_column :photos, :fb_thumbnail_url, :string
  end

  def self.down
    remove_column :photos, :fb_original_url
    remove_column :photos, :fb_thumbnail_url
  end
end
