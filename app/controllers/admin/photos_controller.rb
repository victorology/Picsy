# -*- encoding : utf-8 -*-
class Admin::PhotosController < ApplicationController
  before_filter :authenticate_user!
  layout "admin"
  
  def index
    @photos = Photo.all
  end  
  
  def multiple_destroy
    if params[:photo_ids]
      Photo.destroy_all(["id IN (?)", params[:photo_ids]])
      flash[:message] = "Photo(s) was successfully deleted"
    else
      flash[:message] = "Please choose at least one photo"
    end
    redirect_to :action => "index"
  end
  
end
