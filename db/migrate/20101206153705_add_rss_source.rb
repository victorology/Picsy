class AddRssSource < ActiveRecord::Migration
  def self.up
    add_column :items, :rss_source, :string
    add_column :items, :rss_kind, :string
  end

  def self.down
    remove_column :items, :rss_source
    remove_column :items, :rss_kind
  end
end
