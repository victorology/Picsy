class Admin::ItemLogsController < ApplicationController
  before_filter :authenticate_user!
  # GET /admin/items
  # GET /admin/items.xml
  def index

    @item_logs = ItemLog.paginate :page => params[:page], :order => "created_at", :per_page => 100
    
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @item_logs }
    end
  end
  
  def destroy
    @item_log = ItemLog.find(params[:id])
    @item_log.destroy
    flash[:notice] = "item log was successfully deleted." 
    respond_to do |format|
      format.html { redirect_to(admin_item_logs_url) }
      format.xml  { head :ok }
    end
  end
  

end
