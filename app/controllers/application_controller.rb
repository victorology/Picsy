# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery :except => :check_sign_in 
  before_filter :set_locale
  
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
          :error_message => t("you need to logged in to access this feature"),
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

  def set_locale
    begin 
      @user = current_user
    rescue
      @user = nil
    end    
    
    if params[:language].blank? == false
      I18n.locale = params[:language] 
      Rails.logger.info "SET LANGUAGE BY PARAMS: #{I18n.locale}"
    elsif @user.try(:language).blank? == false
      I18n.locale = @user.language
      Rails.logger.info "SET LANGUAGE BY MODEL: #{I18n.locale}"
    elsif session[:language].blank? == false
      I18n.locale = session[:language]  
      Rails.logger.info "SET LANGUAGE BY SESSION: #{I18n.locale}"
    else    
      I18n.locale = I18n.default_locale
      Rails.logger.info "SET LANGUAGE BY DEFAULT VALUE: #{I18n.locale}"
    end  
    
    session[:language] = I18n.locale
  end  
  
end
