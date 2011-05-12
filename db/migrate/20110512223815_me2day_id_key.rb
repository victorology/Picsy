class Me2dayIdKey < ActiveRecord::Migration
  def self.up
    add_column :users, :me2day_id, :string
    add_column :users, :me2day_key, :string
  end

  def self.down
    remove_column :users, :me2day_id
    remove_column :users, :me2day_key
  end
end
