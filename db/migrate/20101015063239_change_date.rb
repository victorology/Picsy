class ChangeDate < ActiveRecord::Migration
  def self.up
    rename_column :items, :start_date, :begin_date
    rename_column :items, :end_date, :finish_date
  end

  def self.down
    rename_column :items, :begin_date, :start_date
    rename_column :items, :finish_date, :end_date
  end
end
