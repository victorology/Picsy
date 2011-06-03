# -*- encoding : utf-8 -*-
class Admin::PhotosController < ApplicationController
  before_filter :authenticate_user!
  layout "admin"
  
  def index
    @photos = Photo.all
  end  
end
