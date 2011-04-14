class CreatePhotosAddSessionApi < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      t.string :title
      t.integer :user_id
      t.string   :image_file_name
      t.string   :image_content_type
      t.integer  :image_file_size
      t.timestamps
    end
    
    add_column :users, :session_api, :string
  end

  def self.down
    drop_table :photos
    remove_column :users, :session_api
  end
end
