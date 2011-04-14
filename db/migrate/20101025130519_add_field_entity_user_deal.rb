class AddFieldEntityUserDeal < ActiveRecord::Migration
  def self.up
      add_column :user_deals,:entity,:string
  end

  def self.down
      remove_column :user_deals,:entity
  end
end
