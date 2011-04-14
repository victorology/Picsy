class AddExpiredDay < ActiveRecord::Migration
  def self.up
    add_column :items, :expired_day, :integer
  end

  def self.down
    remove_column :items, :expired_day
  end
end
