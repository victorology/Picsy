class AddFacebookFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :facebook_handle, :boolean, :default => false
    add_column :users, :facebook_token, :string
  end

  def self.down
    remove_column :users, :facebook_handle
    remove_column :users, :facebook_token
  end
end
