class CreateItemLogs < ActiveRecord::Migration
  def self.up
    create_table :item_logs do |t|
      t.string :source
      t.text :reason

      t.timestamps
    end
  end

  def self.down
    drop_table :item_logs
  end
end
