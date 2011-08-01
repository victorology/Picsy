# -*- encoding : utf-8 -*-
class Me2dayController < ApplicationController
  skip_before_filter :protect_from_forgery
  before_filter :authenticate_user!, :except => [:confirm]
  
  def connect
    authorize_path = Me2day::Client.get_auth_url(:app_key => ME2DAY_KEY)
    #redirect_to auth_url        

    session[:picsy_me2day] = {:id => params[:id], :session_api => params[:session_api]}  
    
    Rails.logger.info "SESSION ON CONNECT #{session.inspect}" 

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
    Rails.logger.info "SESSION ON CONFIRM #{session.inspect}" 
    if !params[:result].blank? and params[:result].eql?('true')
      @client = Me2day::Client.new(
        :user_id => params[:user_id], :user_key => params[:user_key], :app_key => ME2DAY_KEY
      )
      
      #user_info = @client.get_person(params[:user_id])
      #user.nickname = user_info["nickname"]
      begin
        Rails.logger.info "Class Name #{@client.noop.class}"
        Rails.logger.info "Data Noop #{@client.noop}"
        
        if JSON.parse(@client.noop)["code"].to_s == "0" #"성공했습니다."
          @api_user = User.where(:id => session[:picsy_me2day][:id], :session_api => session[:picsy_me2day][:session_api]).try(:first) 
          @api_user.update_attributes(
            {
              :me2day_key => params[:user_key],
              :me2day_id => params[:user_id]  ,
              :me2day_nickname => @client.get_person(params[:user_id])["nickname"]
            }
          ) 
          me2day_connected = true
          code = 0
          msg = nil
        else
          me2day_connected = false
          code = 1
          msg = JSON.parse(@client.noop)["message"]
        end
      rescue Me2day::Client::UnauthenticatedError => me2
        me2day_connected = false
        code = 1
        msg = "Authentication failed, you might enter wrong username or password"
        Rails.logger.info "AUTH ERROR : #{me2.message} BACKTRACE #{me2.backtrace}"
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
    
  end
  
  def unlink
    current_user.update_attributes(:me2day_key => nil, :me2day_id => nil, :me2day_nickname => nil)
    session[:picsy_me2day] = nil
    
    respond_to do |format|
      format.html {
        flash[:notice] = "your account has been unlinked from me2day successfully"
        redirect_to connections_path
      }
      format.json {
        @raw_result = {
          :code => 0,
          :error_message => nil,
          :value => {
            :me2day => {
              :unlink => current_user.me2day_connected? ? "failed" : "success"
            },
          }
        }
        render :json => JSON.generate(@raw_result)
      }  
    end   
  end
end