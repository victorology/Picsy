class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :remember_me, :nickname, :first_name, :last_name, :twitter_token, :twitter_secret, :twitter_nickname, :facebook_token, :facebook_nickname

  validates_presence_of :email, :nickname
  validates_presence_of :password, :on => :create 
  validates_uniqueness_of :email
  
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  
  validates_uniqueness_of :nickname
  validates_length_of :password, :minimum => 4, :too_short => "minimum is 4 characters", :on => :create
  
  has_many :user_deals
  has_many :item_types, :through => :user_deals, :conditions => ["user_deals.entity='ItemType'"]
  has_many :categories, :through => :user_deals, :conditions => ["user_deals.entity='Category'"]
  has_many :photos
  
  before_save :downcase_email
  
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
  
  
  def update_session_api
    self.update_attribute(:session_api,UUID.new.generate.gsub("-",""))
  end  
  
  protected
  
  def downcase_email
    write_attribute(:email,self.email.downcase)
  end  
  
  
end
