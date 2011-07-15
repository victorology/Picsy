class AddMe2dayNickname < ActiveRecord::Migration
  def self.up
    add_column :users, :me2day_nickname, :string
  end

  def self.down
    remove_column :users, :me2day_nickname
  end
end
