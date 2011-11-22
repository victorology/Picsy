class UtilitiesController < ApplicationController

  def check_sns_key
    result = {}
    result[:facebook] = check_facebook_key
    
    respond_to do |format|
      format.json {
        @raw_result = {
          :code => 0,
          :error_message => nil,
          :value => result
        }

        render :json => JSON.generate(@raw_result), :content_type => Mime::JSON
      }
    end  
  end
  
  protected
  def check_facebook_key
    rs = nil
    if current_user.facebook_connected? == true
      begin
        client = FacebookOAuth::Client.new(
          :application_id => FACEBOOK_APPLICATION_ID,
          :application_secret => FACEBOOK_APPLICATION_SECRET,
          :token => current_user.facebook_token
        )
        rs = {
          :expired => false,
          :account_info => client.me.info
        } 
      rescue OAuth2::HTTPError
        facebook_expired
      rescue OAuth2::AccessDenied   
        facebook_expired
      end   
    else
      facebook_expired  
    end
    
    return rs
  end
  
  def check_twitter_key

  end
  
  def check_tumblr_key
    
  end
  
  def check_me2day_key
    
  end
  
  def facebook_expired
    current_user.update_attributes(
      :facebook_token =>nil,
      :facebook_nickname => nil,
      :facebook_id => nil
    )
    
    rs = {
      :expired => true,
      :account_info => nil
    }
  end  
  
         

end
