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
        :error_message => "failed to authorize, you supply wrong password or username",
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
        :error_message => "login failed, access token & secret don't match, pls try to authorize first",
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
        flash[:notice] = "you have linked to twitter already"
      else  
        current_user.update_attributes(:twitter_token => access_token.token, :twitter_secret => access_token.secret, :twitter_nickname => client.info["screen_name"])
        flash[:notice] = "your account has been linked successfully to twitter"
        #session[:twitter] = {}
        #session[:twitter][:nickname] = access_token.params[:screen_name]
        #session[:twitter][:password] = access_token.secret
        #session[:twitter][:twitter_token] = access_token.token
        #session[:twitter][:twitter_secret] = access_token.secret
      end
    else
      flash[:notice] == "twitter connection is failed, please try again"
      
    end
    redirect_to connections_path     
  end   
  
  def unlink
    current_user.update_attributes(:twitter_token => nil, :twitter_secret => nil, :twitter_nickname => nil)
    flash[:notice] = "your account has been unlinked from twitter successfully"
    redirect_to connections_path
  end  
  
  def assign_categories_locations
    @item_types = ItemType.find(:all)
    @categories = Category.find(:all)
    @user = User.new
    render :layout => "register"
  end 
  
  def do_assign_categories_locations
    @user = User.new(session[:twitter].merge(params[:user]))
    @user.twitter_handle = true
    
    if @user.save
      sign_in @user
      selected_deals(@user.id)
      session[:twitter] = nil
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
    
  def twitter_connect
    return TwitterOAuth::Client.new(:consumer_key => TWITTER_CONSUMER_KEY,:consumer_secret => TWITTER_CONSUMER_SECRET)  
  end  
end
