class AddNoneStatus < ActiveRecord::Migration
  def self.up
    ### none_status = true, it means items will show depend on Categories only
    ### so it doesn't matter what the Location will be
    
    ### none status = false, it means item will show depend on both Categories and Locations
    add_column :items, :none_status, :boolean, :default => false
  end

  def self.down
    remove_column :items, :none_status
  end
end
