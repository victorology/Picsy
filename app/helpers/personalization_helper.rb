module PersonalizationHelper
  
  ### pls note that, Category in UI means ItemTypes in the table
  ### and Locations in UI means Categories in the table
  
  def find_item(location_id)
  	 UserDeal.find(:first,:conditions => ["user_id = #{current_user.id} AND type_id = #{location_id} AND entity ='ItemType' "])
  end

  def find_categeory(categeory_id)
  	UserDeal.find(:first,:conditions => ["user_id = #{current_user.id} AND type_id = #{categeory_id} AND entity ='Category' "])
  end

  def assigned_check_boxes(user_array,user)
    if user && user_array
      user_array.include?("#{item.id}")
    else
      false
    end
  end

  def find_childs(parent_category_id)
    Category.find(:all,:conditions => ["parent_id = #{parent_category_id}"])
  end
  
  def check_sub_category(cat)
    rs = ""
    if cat.children.size > 0
      cat.children.each do |child|
        rs << "$('cat_check_#{child.id}').checked=true;"
      end  
    else
      rs= "void(0);"  
    end
    return rs  
  end  

end

