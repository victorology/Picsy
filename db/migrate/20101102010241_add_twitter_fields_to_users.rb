class AddTwitterFieldsToUsers < ActiveRecord::Migration
  def self.up  
    add_column :users, :twitter_handle, :boolean, :default => false
    add_column :users, :twitter_token, :string
    add_column :users, :twitter_secret, :string
  end

  def self.down
    remove_column :users, :twitter_handle
    remove_column :users, :twitter_token
    remove_column :users, :twitter_secret
  end
end
