class RemoveItemIdCategory < ActiveRecord::Migration
  def self.up
    remove_column :categories, :item_id
  end

  def self.down
    add_column :categories, :item_id, :integer
  end
end
