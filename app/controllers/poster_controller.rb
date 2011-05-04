class PosterController < ApplicationController
  ### this controller is used for testing purpose only
  ### particularly to test POST request against PUMPL API
  
  def show
    #if Rails.env != "production"
      session["warden.user.user.key"] = nil
      @user = User.new
      @photo = Photo.new
      @photo_user = User.find(:first, :conditions => {:nickname => params[:id]})
      @photo_user.update_session_api if @photo_user.session_api.blank?
      
      #@fb_user = User.find(:first,:conditions => {:facebook_handle => true, :email => "aditya.jamop@gmail.com"})
      render :layout => false
    #else
      #redirect_to "/"
    #end    
  end  
end
