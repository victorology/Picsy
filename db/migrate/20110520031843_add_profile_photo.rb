class AddProfilePhoto < ActiveRecord::Migration
  def self.up
    add_column :users, :profile_photo, :string
  end

  def self.down
    remove_column :users, :profile_photo
  end
end
