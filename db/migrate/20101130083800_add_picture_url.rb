class AddPictureUrl < ActiveRecord::Migration
  def self.up
    add_column :items, :picture_url, :string
  end

  def self.down
    remove_column :items, :picture_url
  end
end
