class AddWidthHeightPhoto < ActiveRecord::Migration
  def self.up
    add_column :photos, :image_width, :string
    add_column :photos, :image_height, :string
  end

  def self.down
    remove_column :photos, :image_width
    remove_column :photos, :image_height
  end
end
