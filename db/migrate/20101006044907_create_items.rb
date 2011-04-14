class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.string :title
      t.text :description
      t.string :url
      t.string :image_path
      t.float :deal_price
      t.float :original_price
      t.date :start_date
      t.date :end_date
      t.integer :category_id
      t.integer :item_type_id
      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
