class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.string :var
      t.string :value

      t.timestamps
    end
    add_column :items, :is_expired, :boolean ,:default => false
  end

  def self.down
    drop_table :settings
    remove_column :items, :is_expired
  end
end
