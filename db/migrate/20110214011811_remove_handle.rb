class RemoveHandle < ActiveRecord::Migration
  def self.up
    remove_column :users, :facebook_handle
    remove_column :users, :twitter_handle
    add_column :users, :facebook_nickname, :string
    add_column :users, :twitter_nickname, :string
  end

  def self.down
    add_column :users, :facebook_handle, :string
    add_column :users, :twitter_handle, :string
    remove_column :users, :facebook_nickname
    remove_column :users, :twitter_nickname
  end
end
