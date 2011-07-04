class AddFilter < ActiveRecord::Migration
  def self.up
    add_column :photos, :filter, :string, :default => "Normal"
  end

  def self.down
    remove_column :photos, :filter
  end
end
