class RemoveItemsIsExpired < ActiveRecord::Migration
  def self.up
    remove_column :items, :is_expired
  end

  def self.down
    add_column :items, :is_expired, :boolean
  end
end
