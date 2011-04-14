class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name
      t.integer :item_id
      t.integer :parent_id

      t.timestamps
    end
    
    execute "ALTER SEQUENCE categories_id_seq RESTART WITH 19";
  end

  def self.down
    drop_table :categories
  end
end
