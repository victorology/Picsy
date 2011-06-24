class FoursquareController < ApplicationController
  skip_before_filter :protect_from_forgery
  before_filter :authenticate_user!
   
  def connect
    #redirect_to client.web_server.authorize_url(:redirect_uri => FOURSQUARE_CALLBACK,:client_id => ).gsub("/oauth","/oauth2")+"&display=touch"
    authorize_url = "https://foursquare.com/oauth2/authenticate"
    authorize_url +=  "?client_id=#{FOURSQUARE_KEY}&display=touch"
    authorize_url += "&response_type=code&redirect_uri=#{FOURSQUARE_CALLBACK}/#{params[:session_api]}/id/#{params[:id]}.json"
    
    respond_to do |format|
      format.json {
        @raw_result = {
          :code => 0,
          :error_message => nil,
          :value => {
            :authorize_url => authorize_url
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
    
    access_token_url = "https://foursquare.com/oauth2/access_token?client_id=#{FOURSQUARE_KEY}"
    access_token_url += "&client_secret=#{FOURSQUARE_SECRET}&grant_type=authorization_code"
    access_token_url += "&redirect_uri=#{FOURSQUARE_CALLBACK}&code=#{params[:code]}"
    
    access_token_json = HTTPClient.new.get_content(access_token_url)
    access_token = JSON.parse(access_token_json)["access_token"]
    
    if access_token.blank?
      @raw_result = {
        :code => 1,
        :error_message => "connection failed, please try again",
        :value => {
          :is_foursquare_connected => false
        }
      }  
    else  
      current_user.update_attribute(:foursquare_token,access_token)
      @raw_result = {
        :code => 0,
        :error_message => nil,
        :value => {
          :is_foursquare_connected => true
        }
      }
    end
    
    respond_to do |format|
      format.json {
        render :json => JSON.generate(@raw_result), :content_type => "application/json"
      }
    end

  end  
  
  protected
  
  def client
    OAuth2::Client.new(FOURSQUARE_KEY, FOURSQUARE_SECRET, :site => 'https://www.foursquare.com')
  end  
end
