# -*- encoding : utf-8 -*-
class Admin::ItemTypesController < ApplicationController
  before_filter :authenticate_user!
  # GET /admin/item_types
  # GET /admin/item_types.xml
  def index
    redirect_to new_admin_item_type_path

  end

  # GET /admin/item_types/new
  # GET /admin/item_types/new.xml
  def new
    @item_types = ItemType.all
    @item_type = ItemType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @item_type }
    end
  end

  # GET /admin/item_types/1/edit
  def edit
    @item_type = ItemType.find(params[:id])
  end

  # POST /admin/item_types
  # POST /admin/item_types.xml
  def create
    @item_types = ItemType.all
    @item_type = ItemType.new(params[:item_type])

    respond_to do |format|
      if @item_type.save
        format.html { redirect_to(new_admin_item_type_path, :notice => 'Category was successfully created.') }
        format.xml  { render :xml => @item_type, :status => :created, :location => @item_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @item_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin/item_types/1
  # PUT /admin/item_types/1.xml
  def update
    @item_type = ItemType.find(params[:id])

    respond_to do |format|
      if @item_type.update_attributes(params[:item_type])
        format.html { redirect_to(new_admin_item_type_path, :notice => 'Category was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/item_types/1
  # DELETE /admin/item_types/1.xml
  def destroy
    @item_type = ItemType.find(params[:id])
    @item_type.destroy
    
    respond_to do |format|
      format.html { redirect_to(admin_item_types_url) }
      format.xml  { head :ok }
    end
  end
end
