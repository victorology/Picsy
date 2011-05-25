# -*- encoding : utf-8 -*-
class PersonalizationController < ApplicationController
  before_filter :authenticate_user!, :except => [:user_creation, :sub_categories, :new_user, :user_sign_in, :ajax_user_creation]
  before_filter :convert_api_params, :only => [:user_creation]
  protect_from_forgery :except => [:user_creation]
  
  
  def user_sign_in
    @user = User.new
    render :layout => "register"
  end  
  
  def sign_in_done
    flash[:notice] = "you have logged in successfully"
    redirect_to my_path
  end  
 
  def new_user
    @item_types = ItemType.find(:all)
    @categories = Category.find(:all)
    
    @categories_for_json = []
    @locations_for_json = []
    
    @item_types.each do |itype|
      @categories_for_json << {:id => itype.id, :name => itype.name}
    end
    
    @categories.each do |cat|
      @locations_for_json << {:id => cat.id, :name => cat.name}
    end  
    
      
    respond_to do |format|
      format.json {
        @raw_result = {
          :code => 0,
          :error_message => nil,
          :value => {
            :categories => @categories_for_json,
            :locations => @locations_for_json
          }
        }
        render :json => JSON.generate(@raw_result), :content_type => Mime::JSON
      }
      format.html {render :layout => "register"}
    end 
  end     

  def show
    @items = ItemType.find(:all)
	  @categeories_parent = Category.find(:all,:conditions => ["parent_id is null"])	 
  end
  
  def create
  
    @deals = UserDeal.find(:first,:conditions =>  ["user_id = #{current_user.id}  AND entity = 'ItemType' "])
 
    if !@deals.blank?
      UserDeal.delete_all(["user_id = #{current_user.id} AND entity = 'ItemType' "])
      if !params[:chk_location].blank?
		    params[:chk_location].each_with_index do |loc, i|
		      UserDeal.create(:user => current_user, :entity => "ItemType", :type_id => loc.to_i)
        end
	    end
	  else
      if !params[:chk_location].blank?
		    params[:chk_location].each_with_index do |loc, i|
		      UserDeal.create(:user => current_user, :entity => "ItemType", :type_id => loc.to_i)
        end
      end
    end

    @deals = UserDeal.find(:first,:conditions => ["user_id = #{current_user.id} AND entity = 'Category'"])
    if !@deals.blank? 
	    UserDeal.delete_all(["user_id = #{current_user.id} AND entity ='Category' "])
	    if !params[:chk_categeory].blank?
        params[:chk_categeory].each_with_index do |cat, i|
          UserDeal.create(:user => current_user, :entity => "Category", :type_id => cat.to_i)  
        end
      end
	  else
	    if !params[:chk_categeory].blank?
        params[:chk_categeory].each_with_index do |cat, i|
          UserDeal.create(:user => current_user, :entity => "Category", :type_id => cat.to_i)
        end
      end 
    end
    
    flash[:user_notice] = "Deal has been Saved Successfully"
    redirect_to :action => 'index' and return

  end

  def index
    @locations = UserDeal.find(:all,:conditions => ["user_deals.user_id = #{current_user.id} AND entity = 'Category' "])
    @categeries = UserDeal.find(:all,:conditions =>  ["user_deals.user_id = #{current_user.id} AND entity = 'ItemType'"])
  end
  
  def mydeals
    hold_category_item_type
    @items = Item.mydeals(current_user,params[:controller],params[:page])
    @next_items = Item.mydeals(current_user,params[:controller],params[:page].to_i + 1)
    if @items.size > 0
      render :template => "home/index"
    else
      render :action => "mydeals"
    end    
  end  

  def sub_categories  
    @main_id = params[:id]
    @sub_cats = Category.find(:all,:conditions => ["parent_id = #{params[:id]}"])
    render :partial => "sub_categories" and return
  end

  def user_creation
    @user = User.new(params[:user])

    if @user.valid?
      @user.save
      sign_in @user
      @user.update_session_api if params[:format] == "json"
      @registered_user = {
        :id => @user.id,
        :nickname => @user.nickname,
        :email => @user.email,
        :session_api => @user.session_api
      }
      @result = true
    else
      @result = false  
    end
    
    
    if @result == true
      flash[:notice] = "Thank you for signing up"
	  else
      flash[:user_creation_fail_notice] = "Failed to register due to: #{@user.errors.full_messages.join(', ')}"
	  end	  
	  
	  respond_to do |format|
	    format.json {     
	      @raw_result = {
          :code => (@result == true) ? 0 : 1,
          :error_message => (@result == true) ?  nil : flash[:user_creation_fail_notice] ,
          :value => {
            :registered_user => @registered_user
          }
        }
        render :json => JSON.generate(@raw_result), :content_type => Mime::JSON
	    }
	    format.html {
	      redirect_to my_path if @result == true
	    }
	  end  
  end
  
  
  def ajax_user_creation   
    @user = User.new(params[:user])
    
    if @user.valid?
      @user.save
      sign_in @user
      @result = true
    else
      @result = false  
    end    
    
    render :update do |page|
      if @result == true
        flash[:notice] = "Thank you for signing up"
        page.call "Modalbox.resizeToContent" 
        page.assign "window.location", my_path
      else  
        page.replace_html "register_alert","#{@user.errors.full_messages.join('<br />')}"
        page.call "Modalbox.resizeToContent"  
      end     
    end  
        
  end
  
  protected
  
  ### convert params that come from API, this will be used by iPhone/Android app
  def convert_api_params
    params[:chk_categeory] = params[:categories].split(",") unless params[:categories].blank?
    parans[:chk_location] = params[:locations].split(",") unless params[:locations].blank?
  end  

  
end
