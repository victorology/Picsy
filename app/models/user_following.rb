class UserFollowing < ActiveRecord::Base

  belongs_to :follower, :class_name => "User", :foreign_key => "follower_id"
  belongs_to :following, :class_name => "User", :foreign_key => "following_id"

  validates_presence_of :follower_id, :following_id
end
