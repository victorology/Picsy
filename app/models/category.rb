class Category < ActiveRecord::Base
  has_and_belongs_to_many :items
  belongs_to :parent, :class_name => "Category", :foreign_key => :parent_id
  has_many :children, :class_name => "Category", :foreign_key => :parent_id
  validates_presence_of :name
  validates_uniqueness_of :name
  
  ## get child & it's parent .. not parent with its child
  ## so the approach is down - top NOT top - down
  
  def self.collect_parent_children_ids_by_name(child_name)
    ids = []
    categories = Category.find(:all, :conditions => ["name IN (?) ",child_name])
    categories.each do |cat|
      ids << cat.id
      ids << cat.children.collect {|child| child.id} if cat.children.size > 0
    end  
    return ids.flatten.uniq
  end  
  
  def self.mine(user,controller = "")
    if user and controller=="personalization"
      return user.categories   
    else  
      return Category.all
    end  
  end
  
  def self.parents_mine(user,controller)
    if user and controller=="personalization"
      return user.categories.find(:all, :conditions => {:parent_id => nil})   
    else  
      return Category.find(:all, :conditions => {:parent_id => nil})   
    end
  end  
end
