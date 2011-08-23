class AddLanguage < ActiveRecord::Migration
  def self.up
    add_column :users, :language, :string, :default => "kr"
  end

  def self.down
    remove_column :users, :language
  end
end
