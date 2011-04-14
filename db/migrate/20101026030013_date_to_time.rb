class DateToTime < ActiveRecord::Migration
  def self.up
    change_column :items, :begin_date, :datetime
    change_column :items, :finish_date, :datetime
    remove_column :items, :expired_day
    add_column :items, :expired_timestamp, :float
  end

  def self.down
    change_column :items, :begin_date, :date
    change_column :items, :finish_date, :date
    remove_column :items, :expired_timestamp
    add_column :items, :expired_day, :integer
  end
end
