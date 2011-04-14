class CategoriesItems < ActiveRecord::Migration
  def self.up
    create_table(:categories_items,:id => false) do |t|
      t.integer :category_id
      t.integer :item_id
    end  
    remove_column :items, :category_id
  end

  def self.down
    drop_table :categories_items
    add_column :items, :category_id, :integer
  end
end
