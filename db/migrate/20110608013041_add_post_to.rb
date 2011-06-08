class AddPostTo < ActiveRecord::Migration
  def self.up
    ["facebook","twitter","tumblr"].each do |socmed|
      add_column :photos, "post_to_#{socmed}", :string
    end  
  end

  def self.down
    ["facebook","twitter","tumblr"].each do |socmed|
      remove_column :photos, "post_to_#{socmed}"
    end
  end
end
