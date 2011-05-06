# -*- encoding : utf-8 -*-
module ApplicationHelper
  def number_to_currency(number,options = {})
    rs = super(number,options).to_s
    rs.gsub!("$","")
    0.upto(9) do |i|
      if rs.include?(".#{i}0")
        rs = (i==0) ? rs.gsub(".00","") : rs.gsub(".#{i}0",".#{i}")
        Rails.logger.info "CURR : #{rs}"
      end
    end 
    return rs
  end  
  
  def expired_header(item)
    unless @expired_row
      @expired_row = 1 
      expired_header_step = Setting.find_by_var("expired_header_step")
      if expired_header_step.nil? 
        expired_header_step = Setting.create(:var => "expired_header_step", :value => "0")  
      elsif params[:page] == 1  
        expired_header_step.update_attribute(:value , "0")
      end
      @expired_header_step = expired_header_step.value.to_i
    end
    
    if item.deal_status == DealStatus::AVAILABLE and  @expired_header_step == 0
      @expired_header_step = 1
      expired_header_step_update(1)
      rs = raw("<div id='available_deals'>Available Deals</div>")
    elsif item.deal_status == DealStatus::SOLD_OUT and @expired_header_step < 2
      @expired_header_step = 2
      expired_header_step_update(2)
      rs = raw("<div id='sold_out_deals'>Sold Out Deals</div>")
    elsif item.deal_status == DealStatus::EXPIRED and @expired_header_step < 3
      @expired_header_step = 3  
      expired_header_step_update(3)
      rs = raw("<div id='expired'>Expired Deals</div>")
    end  
    
    @expired_row+=1
    return rs
  end  
  
  def expired_header_step_update(value="0")
    expired_header_step = Setting.find_by_var("expired_header_step")
    expired_header_step.update_attribute(:value,value)  
  end  
  
  
   def count_of_deals(location_id,parent_id)
    if parent_id == nil	  
	  parent_count = 0
	  @sub_categories = Category.find(:all,:select=> :id,:conditions => ["parent_id = #{location_id}"])
	  for sub_cat in @sub_categories
	  	 child_count = Category.find(:first,:conditions => ["id = #{sub_cat.id}"])
		 parent_count = parent_count + child_count.items.size
	  end
	  @main_category = Category.find(:first,:conditions => ["id = #{location_id}"])
	 return parent_count + @main_category.items.size
	 else
	 	child_count = Category.find(:first,:conditions => ["id = #{location_id}"])
		return child_count.items.size
	  end
 
  end
  
     
  def signupfind_childs(parent_category_id)
    Category.find(:all,:conditions => ["parent_id = #{parent_category_id}"])
  end
  

  def find_item(location_id)
	  UserDeal.find(:first,:conditions => ["user_id = #{current_user.id} AND type_id = #{location_id} AND entity ='Location' "])
  end

  def find_categeory(categeory_id)
    UserDeal.find(:first,:conditions => ["user_id = #{current_user.id} AND type_id = #{categeory_id} AND entity ='Categeory' "])
  end
  
  def last_category_name
    return (session[:category_name].kind_of?(Array) ? session[:category_name].last : "All")
  end  
  
  def last_item_type_name
    return (session[:item_type_name].kind_of?(Array) ? session[:item_type_name].last : "All")
  end  
  
  def more_replacement(page)
    if @next_items.size > 0
      page.replace_html 'more', :partial => "home/more_link", :locals => {:page => params[:page].to_i + 1}
      page.show "more"
    else
      page.hide 'more'
    end
  end

  def flash_messages
    message = ""
    if !flash[:notice].blank?
      message += flash[:notice]
    elsif !flash[:error].blank?
      message += flash[:error]
    end
    message
  end

  def clear_flash
    flash[:notice] = nil
    flash[:error] = nil
  end
  
  
end
