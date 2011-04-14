class AddIsHide < ActiveRecord::Migration
  def self.up
    add_column :items, :is_hide, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :items, :is_hide
  end
end
