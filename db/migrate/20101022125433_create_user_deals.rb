class CreateUserDeals < ActiveRecord::Migration
  def self.up
    create_table :user_deals do |t|
      t.integer :user_id
      t.string :type
      t.integer :type_id
      t.timestamps
    end
  end

  def self.down
    drop_table :user_deals
  end
end
