class CreateUserFollowings < ActiveRecord::Migration
  def self.up
    create_table :user_followings do |t|
      t.integer :follower_id
      t.integer :following_id
      t.timestamps
    end
  end

  def self.down
    drop_table :user_followings
  end
end
