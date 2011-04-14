class CreateItemStats < ActiveRecord::Migration
  def self.up
    create_table :item_stats do |t|
      t.float :revenue
      t.integer :sales_ranking
      t.integer :revenue_ranking
      t.integer :item_id

      t.timestamps
    end
    
    add_column :items, :score, :float
  end

  def self.down
    drop_table :item_stats
    remove_column :items, :score
  end
end
