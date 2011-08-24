# -*- encoding : utf-8 -*-
class Devise::SessionsController < ApplicationController
  prepend_before_filter :require_no_authentication, :only => [ :new, :create ]
  include Devise::Controllers::InternalHelpers

  # GET /resource/sign_in
  def new
    clean_up_passwords(build_resource)
    render_with_scope :new
  end

  # POST /resource/sign_in
  def create
    params[:user][:email] = params[:user][:email].downcase if params[:user]
    resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")
    set_flash_message :notice, :signed_in
    sign_in_and_redirect(resource_name, resource)
  end

  # GET /resource/sign_out
  def destroy
    session[:facebook] = nil
    signed_in = signed_in?(resource_name)
    sign_out_and_redirect(resource_name)
    set_flash_message :notice, :signed_out if signed_in
  end
  
  ### custom authentication
  
  def check_sign_in
    params[:user][:email] = params[:user][:email].downcase if params[:user]
    sign_out :user if signed_in?(:user)
    resource = warden.authenticate(:scope => resource_name)
    
    if resource
      resource.update_attribute(:language, params[:language])
      flash[:notice] = t("you have logged in successfully")
    else
      @msg = t("password or email you entered incorrect, please try it again")
    end    
    
    respond_to do |format|
      format.js {
        render :update do |page|   
        
        if resource
          page.call "to_mydeals" 
        else
          page.replace_html "login_alert", @msg
          page.call "Modalbox.resizeToContent"
        end   
        #page.alert(params.inspect + "resource = " + resource.inspect)
      end
      }
      format.json {
        if resource
          resource.update_session_api
          @user = {
            :nickname => resource.nickname,
            :email => resource.email,
            :id => resource.id,
            :session_api => resource.session_api
          }
        end  
        
        @raw_result = {
          :code => (resource.blank?) ? 1 : 0,
          :error_message => @msg,
          :value => {
            :registered_user => @user,
          }
        }
        
        render :json => JSON.generate(@raw_result), :content_type => Mime::JSON
      }
    end  
  end
  
  def update_password
    @api_user = User.find(:first, :conditions => {:id => params[:id], :session_api => params[:session_api]})
    
    params[:user] = {
      :email => @api_user.email,
      :password => params[:old_password]  
    } 
    
    sign_out :user if signed_in?(:user)
    resource = warden.authenticate(:scope => resource_name)
    
    if resource
      resource.password = params[:password]
      resource.password_confirmation = params[:password_confirmation]
      if params[:password].blank?
        @msg = t("new password can't be blank")
      elsif params[:password] != params[:password_confirmation]
        @msg = t("new password and new password confirmation doesn't match")  
      elsif current_user.save
        resource.update_session_api
        @user = {
          :nickname => resource.nickname,
          :email => resource.email,
          :id => resource.id,
          :session_api => resource.session_api
        }
      else
        @msg = t("password and password confirmation doesn't match")
      end    
    else
      @msg = t("the old password you entered incorrect, please try it again")
    end
    
    respond_to do |format|
      format.json {
        @raw_result = {
          :code => (resource.blank?) ? 1 : 0,
          :error_message => @msg,
          :value => {
            :user => @user,
          }
        }
        
        render :json => JSON.generate(@raw_result), :content_type => Mime::JSON
      }
    end  
  end  
   
end
