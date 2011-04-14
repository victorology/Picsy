class RemoveDescription < ActiveRecord::Migration
  def self.up
    remove_column :items, :description
    change_column :items, :title, :text
  end

  def self.down
    add_column :items, :description, :text
    change_column :items, :title, :string
  end
end
