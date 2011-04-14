class AddCodeToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :code, :string
  end

  def self.down
    remove_column :photos, :code
  end
end
