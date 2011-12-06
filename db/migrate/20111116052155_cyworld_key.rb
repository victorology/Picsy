class CyworldKey < ActiveRecord::Migration
  def self.up
    add_column :users, :cyworld_key, :string
    add_column :users, :cyworld_secret, :string
    remove_column :users, :cyworld_request_token_response
    remove_column :users, :cyworld_access_token_response
  end

  def self.down
    remove_column :users, :cyworld_key
    remove_column :users, :cyworld_secret
    add_column :users, :cyworld_request_token_response, :string
    add_column :users, :cyworld_access_token_response, :string
  end
end
