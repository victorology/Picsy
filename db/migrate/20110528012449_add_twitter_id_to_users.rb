class AddTwitterIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :twitter_id, :string
  end

  def self.down
    remove_column :users, :twitter_id
  end
end
