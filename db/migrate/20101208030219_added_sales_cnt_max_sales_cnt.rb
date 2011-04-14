class AddedSalesCntMaxSalesCnt < ActiveRecord::Migration
  def self.up
    add_column :items, :sales_cnt, :integer, :default => 0
    add_column :items, :max_sales_cnt, :integer, :default => 0
  end

  def self.down
    remove_column :items, :sales_cnt
    remove_column :items, :max_sales_cnt
  end
end
