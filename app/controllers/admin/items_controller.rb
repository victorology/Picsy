class Admin::ItemsController < ApplicationController
  before_filter :authenticate_user!
  # GET /admin/items
  # GET /admin/items.xml
  def index

    #params[:order] = "deal_status, sales_cnt DESC, expired_timestamp,finish_date" if params[:order].blank?
    params[:order] = "id" if params[:order].blank?
    cond_operator = params[:status] == "expired" ? "=" : "!="
    
    @items = Item.paginate :page => params[:page], :order => params[:order], :conditions => ["is_hide = ? AND deal_status#{cond_operator}?", false, DealStatus::EXPIRED]
    @all_categories = Category.all(:order => "id")
    
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @items }
    end
  end
  
  def index_images
    @items = Item.paginate :page => params[:page], :order => "id", :conditions => ["(picture_url IS NOT null or picture_url!='' or (picture_url IS NULL and image_file_size IS NULL)) AND is_hide = ?", false]
    @all_categories = Category.all(:order => "id")
  end  
  
  def manage_images
    ids = []
    params[:image_location].collect.each do |key,value|
      ids << key.to_i if value=="local"
    end
    
    @items = Item.find(:all,:select => "DISTINCT ON (rss_source) rss_source, *", :conditions => ["id IN (?)",ids])
 
    @items.each do |item|
      eval("Scraping::RSS::#{item.rss_kind}.crawl_and_save([item.rss_source])") unless item.rss_source.blank?
    end      
    
    @failed_items = Item.find(:all, :conditions => ["(picture_url IS NOT NULL or picture_url!='' or (picture_url IS NULL and image_file_size IS NULL)) AND id IN (?)",ids])
    
    failed_ids = @failed_items.collect {|fl| fl.id}
    success_ids = ids - failed_ids
    
    if failed_ids.size > 0
      flash[:alert] = "images for item id #{failed_ids.join(',')} can't be localized due to HTTP bad response, you may want to try localize again or upload the image manually"
    end
    
    if success_ids.size > 0
      flash[:notice] = "images for item id #{success_ids.join(',')} has been localized"
    end    
    
    #render :text => flash.inspect
    redirect_to index_images_admin_items_path
  end   

  # GET /admin/items/1
  # GET /admin/items/1.xml
  def show
    @item = Item.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @item }
    end
  end

  # GET /admin/items/new
  # GET /admin/items/new.xml
  def new
    @item = Item.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @item }
    end
  end

  # GET /admin/items/1/edit
  def edit
    @item = Item.find(params[:id])
  end

  # POST /admin/items
  # POST /admin/items.xml
  def create
    @item = Item.new(params[:item])

    respond_to do |format|
      if @item.save
        format.html { redirect_to(admin_item_path(@item), :notice => 'Item was successfully created.') }
        format.xml  { render :xml => @item, :status => :created, :location => @item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin/items/1
  # PUT /admin/items/1.xml
  def update
    @item = Item.find(params[:id])

    respond_to do |format|
      if @item.update_attributes(params[:item])
        format.html { redirect_to(admin_item_path(@item), :notice => 'Item was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/items/1
  # DELETE /admin/items/1.xml
  def destroy
    @item = Item.find(params[:id])
    @item.destroy
    flash[:notice] = "#{@item.title} was successfully deleted." 
    respond_to do |format|
      format.html { redirect_to(admin_items_url) }
      format.xml  { head :ok }
    end
  end
  
  def hide
    @item = Item.find(params[:id])
    @item.update_attribute(:is_hide, true)
    
    flash[:notice] = "#{@item.title} was successfully hidden." 
    respond_to do |format|
      format.html { redirect_to(admin_items_url) }
      format.xml  { head :ok }
    end
  end
  
  def select
    
    params[:item_type_ids].each do |key,value|
      @item = Item.find(key)
      @item.item_type_id = value
      @item.category_ids = (params["item_#{key}".to_s].blank?) ? nil : params["item_#{key}".to_s][:category_ids]
      @item.none_status = params["none_categories_#{key}"] == "1" ? true : false
      @item.save
    end      
    #a.a
    
    flash[:notice] = "category & locations has been updated successfully"
    redirect_to admin_items_path(:page => params[:page], :order => params[:order])
  end  
end
