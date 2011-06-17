class AddFoursquare < ActiveRecord::Migration
  def self.up
    add_column :users, :foursquare_token, :string
    add_column :users, :foursquare_secret, :string
  end

  def self.down
    remove_column :users, :foursquare_token
    remove_column :users, :foursquare_secret
  end
end
