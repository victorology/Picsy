# -*- encoding : utf-8 -*-
class FacebookController < ApplicationController
  protect_from_forgery :except => [:confirm_api]
  before_filter :authenticate_user!
  
  def index
    client = facebook_connect
    authorize_path = client.authorize_url.gsub("offline_access","offline_access,email,user_photos,publish_stream")+"&display=touch"
    
    respond_to do |format|
      format.json {
        @raw_result = {
          :code => 0,
          :error_message => nil,
          :value => {
            :authorize_url => authorize_path
          }
        }
        render :json => JSON.generate(@raw_result)
      }
      format.html {
        redirect_to authorize_path
      }
    end   
  end  
  
  def confirm_api
    begin
      #params[:format] = "json"
      client = facebook_connect
      access_token = client.authorize(:code => params[:code])
      
      @raw_result = {
        :code => 0,
        :error_message => nil,
        :value => {
          :is_facebook_connected => true
        }
      }
      current_user.update_attributes(:facebook_token => access_token.token, 
                                     :facebook_nickname => fb_nickname(client), 
                                     :facebook_id => client.me.info['id'])
    
    rescue OAuth2::HTTPError
      @raw_result = {
        :code => 1,
        :error_message => "failed to authorize facebook, please try again",
        :value => nil
      }
    end    
    render :json => JSON.generate(@raw_result), :content_type => Mime::JSON  
  end  
  
  def confirm
    client = facebook_connect
    access_token = client.authorize(:code => params[:code])
    
    if current_user.facebook_token.blank?
      current_user.update_attributes(:facebook_token => access_token.token, :facebook_nickname => fb_nickname(client))
    end
    
    flash[:notice] = "your account has been linked successfully to facebook"
    redirect_to connections_path
    
  end  
  
  def unlink
    current_user.update_attributes(:facebook_token => nil, :facebook_nickname => nil, :facebook_id => nil)
    respond_to do |format|
      format.html {
        flash[:notice] = "your account has been unlinked from facebook successfully"
        redirect_to connections_path
      }
      format.json {
        @raw_result = {
          :code => 0,
          :error_message => nil,
          :value => {
            :facebook => {
              :unlink => current_user.facebook_connected? ? "failed" : "success"
            },
          }
        }
        render :json => JSON.generate(@raw_result)    
      }  
    end  
  end
  
  def assign_categories_locations
    @item_types = ItemType.find(:all)
    @categories = Category.find(:all)
    @user = User.new
    render :layout => "register"
  end 
  
  def do_assign_categories_locations
    @user = User.new(session[:facebook])
    @user.facebook_handle = true
    
    if @user.save
      sign_in @user
      session[:facebook] = nil
      @result = true 
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
  
  def facebook_connect
    callback = FACEBOOK_CALLBACK
    if params[:format] == "json"
      callback = FACEBOOK_CALLBACK+"facebook/confirm_api/#{params[:session_api]}/id/#{params[:id]}.json"  
    end  
    
    client = FacebookOAuth::Client.new(
      :application_id => FACEBOOK_APPLICATION_ID,
      :application_secret => FACEBOOK_APPLICATION_SECRET,
      :callback => callback
    )
    return client
  end  
end
