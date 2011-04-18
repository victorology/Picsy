class Initial < ActiveRecord::Migration
  def self.up
    create_table "photos", :force => true do |t|
      t.string   "title"
      t.integer  "user_id"
      t.string   "image_file_name"
      t.string   "image_content_type"
      t.integer  "image_file_size"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "code"
      t.string   "image_width"
      t.string   "image_height"
      t.string   "fb_original_url"
      t.string   "fb_thumbnail_url"
    end
  end
  
  create_table "settings", :force => true do |t|
    t.string   "var"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  
  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "",    :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "",    :null => false
    t.string   "password_salt",                       :default => "",    :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.boolean  "is_admin",                            :default => false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "nickname"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "twitter_token"
    t.string   "twitter_secret"
    t.string   "facebook_token"
    t.string   "session_api"
    t.string   "facebook_nickname"
    t.string   "twitter_nickname"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  def self.down
    drop_table :users
    drop_table :settings
    drop_table :photos
  end
end
