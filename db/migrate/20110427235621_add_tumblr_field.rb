class AddTumblrField < ActiveRecord::Migration
  def self.up
    add_column :users, :tumblr_email, :string
    add_column :users, :tumblr_secret, :string
    add_column :users, :tumblr_nickname, :string
  end

  def self.down
    remove_column :users, :tumblr_email
    remove_column :users, :tumblr_secret
    remove_column :users, :tumblr_nickname
  end
end
