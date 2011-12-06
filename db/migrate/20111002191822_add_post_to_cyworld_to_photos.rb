class AddPostToCyworldToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :post_to_cyworld, :string
  end

  def self.down
    remove_column :photos, :post_to_cyworld
  end
end
