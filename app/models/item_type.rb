class ItemType < ActiveRecord::Base
  has_many :items
  validates_presence_of :name
  validates_uniqueness_of :name
  has_many :user_deals, :foreign_key => 'type_id'
  
  def self.mine(user,controller = "")
    if user and controller=="personalization"
      return user.item_types   
    else  
      return ItemType.all
    end  
  end  
end
