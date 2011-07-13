# -*- encoding : utf-8 -*-
class Me2dayController < ApplicationController
  skip_before_filter :protect_from_forgery
  before_filter :authenticate_user!, :except => [:confirm]
  
  def connect
    authorize_path = Me2day::Client.get_auth_url(:app_key => ME2DAY_KEY)
    #redirect_to auth_url        

    session[:picsy_me2day] = {:id => params[:id], :session_api => params[:session_api]}   

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
  
  def confirm
    if !params[:result].blank? and params[:result].eql?('true')
      @client = Me2day::Client.new(
        :user_id => params[:user_id], :user_key => params[:user_key], :app_key => ME2DAY_KEY
      )
      
      if @client.noop["message"] == "성공했습니다."
        @api_user = User.where(:id => session[:picsy_me2day][:id], :session_api => session[:picsy_me2day][:session_api]).try(:first) 
        @api_user.update_attributes(
          {
            :me2day_key => params[:user_key],
            :me2day_id => params[:user_id]  
          }
        ) 
        me2day_connected = true
        code = 0
        msg = nil
      else
        me2day_connected = false
        code = 1
        msg = @client.noop["message"]
      end     
        
      @raw_result = {
        :code => code,
        :error_message => msg,
        :value => {
          :is_me2day_connected => me2day_connected
        }
      }  
      

    else
      @raw_result = {
        :code => 1,
        :error_message => "connection is failed, please try again",
        :value => {
          :is_me2day_connected => false
        }
      }
    end
       
    respond_to do |format|
      format.json {
        session[:me2day] = nil
        render :json => JSON.generate(@raw_result), :content_type => Mime::JSON
      }
    end       
=begin      
      token = UserToken.new(:uid => params[:user_id], :token => params[:user_key], :provider => "me2day")
      if current_user
        current_user.user_tokens.find_or_create_by_provider_and_uid("me2day", params[:user_id])
        flash[:notice] = "Authentication successful"
        redirect_to edit_user_registration_path
      else
        authentication = UserToken.find_by_provider_and_uid("me2day", params[:user_id])
        if authentication
          flash[:notice] = I18n.t "devise.omniauth_callbacks.success"
          sign_in_and_redirect(:user, authentication.user)
        else
          begin
            user = User.find_or_initialize_by_email(:email => "#{params[:user_id]}@me2day.net")
            user = User.new if user.nil?
            if user.nickname.blank?
              user_info = @client.get_person(params[:user_id])
              user.nickname = user_info["nickname"]
            end
            user.user_tokens.build(:provider => "me2day", :uid => params[:user_id], :token => params[:user_key])
          rescue Exception => e
            logger.error e
          end
          if user.save
            flash[:notice] = I18n.t "devise.omniauth_callbacks.success"
            sign_in_and_redirect(:user, user)
          else
            redirect_to new_user_registration_url
          end
        end
      end
=end    

  end
end