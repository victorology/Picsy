class AddCyworldAccessTokenResponseToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :cyworld_access_token_response, :string, :limit => 1000
  end

  def self.down
    remove_column :users, :cyworld_access_token_response
  end
end
