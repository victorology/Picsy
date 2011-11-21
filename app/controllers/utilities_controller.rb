class UtilitiesController < ApplicationController

  def check_sns_key
    result = {}
    result[:facebook] = check_facebook_key
    
    respond_to do |format|
      format.json {
        @raw_result = {
          :code => 1,
          :error_message => nil,
          :value => result
        }

        render :json => JSON.generate(@raw_result), :content_type => Mime::JSON
      }
    end  
  end
  
  protected
  def check_facebook_key
    if current_user.facebook_connected? == true
      begin
        client = FacebookOAuth::Client.new(
          :application_id => FACEBOOK_APPLICATION_ID,
          :application_secret => FACEBOOK_APPLICATION_SECRET,
          :token => current_user.facebook_token
        )
        return client.me.info
      rescue OAuth2::HTTPError
        current_user.update_attribute(:facebook_token,nil)
        "facebook token is expired, facebook token data has been reset"
      end    
    end
  end
  
  def check_twitter_key

  end
  
  def check_tumblr_key
    
  end
  
  def check_me2day_key
    
  end
  
         

end
