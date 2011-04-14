class ItemsController < ApplicationController
  before_filter :find_items
  skip_before_filter :verify_authenticity_token, :only => :filter
  
  def filter
    respond_to do |format|
      format.js {
        render :update do |page|
          page.replace_html 'deals', :partial => "home/item", :collection => @items
          page.hide params[:dom_id]
          
          more_replacement(page)
        end  
      }
    end  
  end
  
  def more
    respond_to do |format|
      format.js { 
        render :update do |page|
          page.insert_html :bottom, 'deals', :partial => "home/item", :collection => @items
          page.hide "loading"
          
          more_replacement(page)
        end  
      }
    end
    
  end  
  
end
