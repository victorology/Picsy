class UtilitiesController < ApplicationController

  def check_sns_key
    result = {}

    result[:facebook] = check_facebook_key
    result[:tumblr] = check_tumblr_key
    result[:twitter] = check_twitter_key
    result[:me2day] = check_me2day_key
    
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
          :info => client.me.info
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
  
  def check_tumblr_key
    rs = nil
    if current_user.tumblr_connected? == true
      data = {
        :email => current_user.tumblr_email,
        :password => User.tumblr_pwd_decrypt(current_user.tumblr_secret)
      }
      
      clnt = HTTPClient.new
      response = clnt.post("http://www.tumblr.com/api/authenticate",data)

      if response.body.include?("Invalid credentials")
        tumblr_expired
      else
        doc = Nokogiri::XML response.body
        rs = {
          :expired => false,
          :info => {
            :email => current_user.tumblr_email,
            :nickname => doc.xpath("//tumblr//tumblelog")[0].attr('name'),
            :url => doc.xpath("//tumblr//tumblelog")[0].attr('url'),
            :avatar_url => doc.xpath("//tumblr//tumblelog")[0].attr('avatar-url'),
          }
        }
      end
    else
      tumblr_expired  
    end      
  end
  
  def check_twitter_key
    rs = nil
    if current_user.twitter_connected? == true
      client = TwitterOAuth::Client.new(
        :consumer_key => TWITTER_CONSUMER_KEY,
        :consumer_secret => TWITTER_CONSUMER_SECRET,
        :token => current_user.twitter_token, 
        :secret => current_user.twitter_secret
      )
      client_info = client.info
      
      if client_info["error"]
        twitter_expired
      else
        info = Hash.new
        ["id","name","location","screen_name","friends_count","description"].each do |key|
          info[key] = client_info[key]
        end  
        rs = {
          :expired => false,
          :info => info
        }
      end     
    else
      twitter_expired
    end     
  end
  
  def check_me2day_key
    rs = nil
    if current_user.me2day_connected? == true
      begin
        @client = Me2day::Client.new(
          :user_id => current_user.me2day_id, 
          :user_key => current_user.me2day_key, 
          :app_key => ME2DAY_KEY
        )
        if JSON.parse(@client.noop)["code"].to_s == "0"
          info = JSON.parse(@client.get_person(current_user.me2day_id))
          rs = {
            :expired => false,
            :info => info.select{|k,v| ["id", "nickname", "description", "email", "friendsCount"].include?(k)}
          }
        else
          me2day_expired
        end
      rescue Me2day::Client::UnauthenticatedError
        me2day_expired
      end
    else
      me2day_expired
    end
  end
  
  def twitter_expired
    current_user.update_attributes(
      :twitter_token => nil,
      :twitter_nickname => nil,
      :twitter_id => nil,
      :twitter_secret => nil
    )
    
    rs = {
      :expired => true,
      :info => nil
    }
  end  
  
  def facebook_expired
    current_user.update_attributes(
      :facebook_token =>nil,
      :facebook_nickname => nil,
      :facebook_id => nil
    )
    
    rs = {
      :expired => true,
      :info => nil
    }
  end  
  
  def tumblr_expired
    current_user.update_attributes(
      :tumblr_email =>nil,
      :tumblr_secret => nil,
      :tumblr_nickname => nil
    )
    
    rs = {
      :expired => true,
      :info => nil
    }
  end  

  def me2day_expired
    current_user.update_attributes(
      :me2day_key => nil,
      :me2day_id => nil,
      :me2day_nickname => nil
    )
    
    rs = {
      :expired => true,
      :info => nil
    }
  end  
  
end
