# -*- encoding : utf-8 -*-
require 'carrierwave/orm/activerecord'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :remember_me, :nickname, :first_name, :last_name, :twitter_token, :twitter_secret, :twitter_nickname, :facebook_token, :facebook_nickname, :facebook_id, :tumblr_email, :tumblr_secret, :tumblr_nickname, :phone_number, :password, :profile_photo

  validates_presence_of :email, :nickname
  validates_presence_of :password, :on => :create 
  validates_uniqueness_of :email
  
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  
  validates_uniqueness_of :nickname
  validates_length_of :password, :minimum => 4, :too_short => "minimum is 4 characters", :on => :create
  
  has_many :photos

  #follower and following
  has_many :user_following, :foreign_key => "follower_id"
  has_many :user_followers, :class_name => "UserFollowing", :foreign_key => "following_id"
  has_many :following, :through => :user_following, :source => "following"
  has_many :followers, :through => :user_followers, :source => "follower"
  
  before_save :downcase_email
  
  mount_uploader :profile_photo, ProfileUploader
  
  def twitter_connected?
    if self.twitter_token and self.twitter_secret
      return true
    else
      return false
    end    
  end  
  
  def facebook_connected?
    return (self.facebook_token.blank?) ? false : true
  end  
  
  def tumblr_connected?
    return (self.tumblr_secret.blank?) ? false : true
  end  
  
  
  def update_session_api
    self.update_attribute(:session_api,UUID.new.generate.gsub("-",""))
  end  
  
  def self.find_for_database_authentication(conditions={})
    self.where("nickname = ?", conditions[:email]).limit(1).first ||
    self.where("email = ?", conditions[:email]).limit(1).first
  end
  
  def self.tumblr_pwd_encrypt(pwd)
    key = EzCrypto::Key.with_password TUMBLR_SECRET, TUMBLR_SALT
    return key.encrypt64(pwd)
  end
  
  def self.tumblr_pwd_decrypt(pwd)
    key = EzCrypto::Key.with_password TUMBLR_SECRET, TUMBLR_SALT
    return key.decrypt64(pwd)
  end      

  def get_following_photos(limit = 10)
    Photo.where("user_id IN (?)", self.following.collect(&:id)).order("created_at DESC").limit(limit)
  end

  def facebook_friends
    if self.facebook_connected? == true   
      clnt = HTTPClient.new
      body = {:access_token => self.facebook_token}
      response = clnt.get("https://graph.facebook.com/me/friends",body)

      rs = JSON.parse(response.content)
      if rs["error"]
        if rs["error"]["message"].include?("Error validating access token")
          self.update_attributes(:facebook_token => nil, :facebook_nickname => nil, :facebook_id => nil)
          message = "this user account isn't connected to Facebook, please authorize it first"
        else
          message = rs["error"]["message"]
        end
        return [false, message]    
      else
        return [true, rs['data']]
      end
    elsif self.facebook_connected? == false 
      message = "Can't retrieve facebook friend ids, you need to link your account first" 
      return [false, message]
    end  
  end
  
  protected
  
  def downcase_email
    write_attribute(:email,self.email.downcase)
  end  
  
  
end
