# -*- encoding : utf-8 -*-
class TwitterController < ApplicationController
  protect_from_forgery :except => [:xauth_token,:xauth_login]
  before_filter :authenticate_user! 

  def index
    client = twitter_connect
    request_token = client.request_token(:oauth_callback => "http://#{request.host_with_port}/#{TWITTER_CONFIRM_PATH}")
    session[:request_token] = request_token.token
    session[:request_secret] = request_token.secret
    redirect_to request_token.authorize_url
  end
  
  def xauth_token
    begin
      if current_user.twitter_secret.blank? or current_user.twitter_token.blank?   
        consumer =  OAuth::Consumer.new TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET, {:site => 'https://api.twitter.com'}  
        token = consumer.get_access_token(nil,{},
          :x_auth_username => params[:x_auth_username],
          :x_auth_password => params[:x_auth_password],
          :x_auth_mode => 'client_auth'
        )
      
        current_user.update_attributes(:twitter_token => token.token, :twitter_secret => token.secret, :twitter_nickname => params[:x_auth_username])
      end  
      
      @raw_result = {
        :code => 0,
        :error_message => nil,
        :value => {
          :is_twitter_connected => true
        }
      }
 
    rescue OAuth::Unauthorized
      @raw_result = {
        :code => 1,
        :error_message => t("authentication failed, you might enter wrong username or password"),
        :value => nil
      }   
    end

    respond_to do |format|
      format.json {
        render :json => JSON.generate(@raw_result), :content_type => Mime::JSON
      }  
    end
  end  
  
  def xauth_login
    #auth = Twitter::OAuth.new(consumer_key, consumer_secret)
    #auth.authorize_from_access(@opts[:oauth_access_token], @opts[:oauth_access_secret])
    #twitter = Twitter::Base.new(auth)
    
    client = TwitterOAuth::Client.new(
      :consumer_key => TWITTER_CONSUMER_KEY,
      :consumer_secret => TWITTER_CONSUMER_SECRET,
      :token => params[:x_auth_access_token], 
      :secret => params[:x_auth_access_secret]
    )

    if client.authorized? == true
      @raw_result = {
        :code => 0,
        :error_message => nil,
        :value => {
          :user_info => client.info
        }
      }
    else
      @raw_result = {
        :code => 1,
        :error_message => t("login failed, access token & secret don't match, please try to authorize first"),
        :value => nil
      }
    end    
    
    respond_to do |format|
      format.json {
        render :json => JSON.generate(@raw_result), :content_type => Mime::JSON
      }
    end
    
    
  end  
        
  def confirm
    client = twitter_connect
    
    access_token = client.authorize(
      session[:request_token],
      session[:request_secret],
      :oauth_verifier => params[:oauth_verifier]
    )
    
    if client.authorized? == true and session[:request_token] and session[:request_secret] 
      if current_user.twitter_token == access_token.token and current_user.twitter_secret == access_token.secret
        flash[:notice] = t("you have linked to twitter already")
      else  
        current_user.update_attributes(:twitter_token => access_token.token, :twitter_secret => access_token.secret, :twitter_nickname => client.info["screen_name"], :twitter_id => client.info["id"])
        flash[:notice] = t("your account has been linked successfully to twitter")
        #session[:twitter] = {}
        #session[:twitter][:nickname] = access_token.params[:screen_name]
        #session[:twitter][:password] = access_token.secret
        #session[:twitter][:twitter_token] = access_token.token
        #session[:twitter][:twitter_secret] = access_token.secret
      end
    else
      flash[:notice] == t("twitter connection is failed, please try again")
      
    end
    redirect_to connections_path     
  end   
  
  def unlink
    current_user.update_attributes(:twitter_token => nil, :twitter_secret => nil, :twitter_nickname => nil, :twitter_id => nil)
    respond_to do |format|
      format.html {
        flash[:notice] = t("your account has been unlinked from twitter successfully")
        redirect_to connections_path
      }
      format.json {
        @raw_result = {
          :code => 0,
          :error_message => nil,
          :value => {
            :twitter => {
              :unlink => current_user.twitter_connected? ? t("failed") : t("success")
            },
          }
        }
        render :json => JSON.generate(@raw_result)
      }  
    end   
  end  
  
  protected
    
  def twitter_connect
    return TwitterOAuth::Client.new(:consumer_key => TWITTER_CONSUMER_KEY,:consumer_secret => TWITTER_CONSUMER_SECRET)  
  end  
end
