class AddMe2dayErrMessage < ActiveRecord::Migration
  def self.up
    add_column :photos, :me2day_error_message, :text
  end

  def self.down
    remove_column :photos, :me2day_error_message
  end
end
