class RemoveFieldUserDeal < ActiveRecord::Migration
  def self.up
 	remove_column :user_deals,:type
  end

  def self.down
  	add_column :user_deals,:type,:string
  end
end
