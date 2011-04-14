module Admin::ItemsHelper
  
  def check_parent_category(cat)
    unless cat.parent.blank?
      return "$('item_category_ids_#{cat.parent.id}').checked=true;"
    else
      return "void(0);"
    end    
  end  
  
  def check_parent_category_on_item(cat,item_id)
    rs = ""
    unless cat.parent.blank?
      rs = "$('item_#{item_id}_category_ids_#{cat.parent.id}').checked=true;"
    end
    rs << "$('all_categories_#{item_id}').checked = false;"
  end  
    
end
