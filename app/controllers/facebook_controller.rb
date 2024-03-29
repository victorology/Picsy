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
        :error_message => t("failed to authorize facebook, please try again"),
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
    
    flash[:notice] = t("your account has been linked successfully to facebook")
    redirect_to connections_path
    
  end  
  
  def unlink
    current_user.update_attributes(:facebook_token => nil, :facebook_nickname => nil, :facebook_id => nil)
    respond_to do |format|
      format.html {
        flash[:notice] = t("your account has been unlinked from facebook successfully")
        redirect_to connections_path
      }
      format.json {
        @raw_result = {
          :code => 0,
          :error_message => nil,
          :value => {
            :facebook => {
              :unlink => current_user.facebook_connected? ? t("failed") : t("success")
            },
          }
        }
        render :json => JSON.generate(@raw_result)    
      }  
    end  
  end
  
  def single_sign_on
    client = FacebookOAuth::Client.new(
        :application_id => FACEBOOK_APPLICATION_ID,
        :application_secret => FACEBOOK_APPLICATION_SECRET,
        :token => params[:fb_access_token]
    )
    
    begin
      @facebook_id = client.me.info["id"]   
      #user = User.where(:facebook_id => @facebook_id).first
    rescue
      @facebook_id = nil
      #user = nil
    end    
      
    unless @facebook_id.blank?
      code = 0
      error_message = nil
      current_user.update_attributes(
        :facebook_token => params[:fb_access_token], 
        :facebook_nickname => fb_nickname(client),
        :facebook_id => @facebook_id
      )

      user_hash = {
        :nickname => current_user.nickname,
        :email => current_user.email,
        :facebook_nickname => current_user.facebook_nickname
      }
    else
      code = 1
      error_message = t("failed to connect to facebook, please try again")  
      user_hash = nil
    end    

    
    @raw_result = {
      :code => code,
      :error_message => error_message,
      :value => {
        :user => user_hash
      }
    }
    render :json => JSON.generate(@raw_result)
  end  

  def albums
    respond_to do |format|
      format.json {
        albums = @api_user.facebook_connected? ? @api_user.facebook_albums : []
        if albums.size > 0   
          albums.sort!{|x,y| x["name"] <=> y["name"]}       
          @raw_result = {
            :code => 0,
            :error_message => nil,
            :value => albums.collect{|album| {:id => album["id"], :name => album["name"]} }
          }
        else
          if @api_user.facebook_connected? 
            message = t("you don't have any facebook albums")
          else
            message = t("You have to connect to facebook to fecth albums")
          end
          @raw_result = {
            :code => 1,
            :error_message => message,
            :value => nil
          }
        end    

        render :json => JSON.generate(@raw_result), :content_type => Mime::JSON
      }
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
