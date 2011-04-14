class AddedDealStatusToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :deal_status, :integer
  end

  def self.down
    remove_column :items, :deal_status
  end
end
