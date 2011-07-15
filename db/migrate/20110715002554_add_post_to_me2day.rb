class AddPostToMe2day < ActiveRecord::Migration
  def self.up
    add_column :photos, :post_to_me2day, :string
  end

  def self.down
    remove_column :photos, :post_to_me2day
  end
end
