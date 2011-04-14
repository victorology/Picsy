class ApplicationController < ActionController::Base
  protect_from_forgery :except => :check_sign_in
  before_filter :init_controller_vars, :clear_unused_session
  
  def init_controller_vars
    params[:item_type_name] = "All" unless params[:item_type_name]
    params[:category_name] = "All" unless params[:category_name]
    params[:page] = 1 unless params[:page]
  end  
  
  def find_items
    hold_category_item_type if params[:controller] == "items" or (params[:controller]=="home" and params[:action]=="index")
    @items = Item.filter(:category_name => params[:category_name],:item_type_name => params[:item_type_name], :page => params[:page])
    @next_items = Item.filter(:category_name => params[:category_name],:item_type_name => params[:item_type_name], :page => params[:page].to_i + 1)  
    
    @number_of_deals = Item.number_of_deals(:category_name => params[:category_name],:item_type_name => params[:item_type_name])
  end
  
  def hold_category_item_type
    session[:category_name] = Array.new if session[:category_name].nil?   
    session[:item_type_name] = Array.new if session[:item_type_name].nil?
    
    if session[:category_name].size > 1 and session[:category_name].include?("All")
      session[:category_name].reject! {|cat| cat=="All"}
    end
      
    if session[:item_type_name].size > 1 and session[:item_type_name].include?("All")
      session[:item_type_name].reject! {|itype| itype=="All"}
    end
    
    unless session[:category_name].include?(params[:category_name])    
      session[:category_name] << params[:category_name] 
    else
      session[:category_name].reject! {|name| name == params[:category_name] }
    end    
    
    unless session[:item_type_name].include?(params[:item_type_name])
      session[:item_type_name] << params[:item_type_name] 
    else
      session[:item_type_name].reject! {|name| name == params[:item_type_name] }
    end
    
    session[:category_name].flatten!
    session[:item_type_name].flatten!    
        
    params[:category_name] = session[:category_name]
    params[:item_type_name] = session[:item_type_name]   
  end
    
  def clear_unused_session
    unless params[:controller] == "items"
      session[:category_name] = nil
      session[:item_type_name] = nil
    end  
  end  
  
  def after_sign_in_path_for(resource_or_scope)
    if resource_or_scope.is_a?(User)
      sign_in_done_personalization_index_url
    else
      super
    end
  end
  
  def fb_nickname(client)
    info = client.me.info 
    rs = info["link"].gsub("http://www.facebook.com/","") 
    if rs.include?("profile.php")
      rs = info["id"]
    end
    return rs  
  end
  
  def authenticate_user!
    if params[:format] == "json" or params[:action] == "confirm_api"
      @api_user = User.find(:first, :conditions => {:id => params[:id], :session_api => params[:session_api]})  
      if @api_user.blank?
        @raw_result = {
          :code => 1,
          :error_message => "you need to logged in to access this feature",
          :value => nil
        }
        render :json => JSON.generate(@raw_result)
        return false
      end 
    else
      super
    end
  end  
  
  def current_user
    if params[:format] == "json"
      @api_user = User.find(:first, :conditions => {:id => params[:id], :session_api => params[:session_api]})  
      return @api_user
    else
      super
    end  
  end    
  
  def selected_deals(user_id)
    ### pls note that, Category in UI means ItemTypes in the table
    ### and Locations in UI means Categories in the table
    
    if !params[:chk_location].blank?
      params[:chk_location].each_with_index do |loc, i|
        @deal = UserDeal.new
        @deal.user_id = user_id
        @deal.entity = 'Category'
        @deal.type_id = loc.to_i
        @deal.save
      end
    end

    if !params[:chk_categeory].blank?
      params[:chk_categeory].each_with_index do |cat, i|
        @deal = UserDeal.new
        @deal.user_id = user_id
        @deal.entity = 'ItemType'
        @deal.type_id = cat.to_i
        @deal.save
      end
    end
  end
end
