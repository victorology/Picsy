class CreateItemTypes < ActiveRecord::Migration
  def self.up
    create_table :item_types do |t|
      t.string :name

      t.timestamps
      
    end
    
    execute "ALTER SEQUENCE item_types_id_seq RESTART WITH 16";
  end

  def self.down
    drop_table :item_types
  end
end
