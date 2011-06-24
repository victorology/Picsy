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
  
  def search_venues
    @venues_arr = []
    opt = {
      :ll => "#{params[:latitude]},#{params[:longitude]}", 
      :query => params[:place]
    }
    opt.delete_if {|key,value| key.to_s == "query"} if params[:place].blank?
    
    
    if params[:latitude].blank? or params[:longitude].blank?
      code = 1
      @err_message = "you need to supply GPS coordinates (latitude & longitude)"
    elsif  current_user.foursquare_token.blank?
      code =1
      @err_message = "foursquare token is invalid, please try to reconnect to foursquare"
    else   
      code = 0
      @venues = client.search_venues opt
      
      if !@venues[:meta].blank? and !@venues[:meta][:errorDetail]
        code = 1
        @err_message = @venues[:meta][:errorDetail] 
      elsif !@venues[:groups].blank? and !@venues[:groups][0].blank? and !@venues[:groups][0][:items].blank?
        ven_hash = {}
        @venues[:groups][0][:items].each_with_index do |ven,ven_idx|
          ven.each do |key,value|
            if @venues[:groups][0][:items][ven_idx][key].class == Hashie::Mash
              ven[key].each do |key2,value2|
                ven_hash[key] = Hash.new if ven_hash[key].blank?
                ven_hash[key][key2] = value2 
              end 
            ## don't need categories for now
            elsif key.to_s!="categories"  
              ven_hash[key] = value
            end
          end  
          @venues_arr <<  ven_hash
        end  
        code = 0
      else
        code = 1
        @err_message = "Failed to retrieve venues, please try again"  
      end    
    end  
  
    
    @raw_result = {
      :code => code,
      :error_message => @err_message,
      :value => {
        :venues => @venues_arr
      }
    }
    
    respond_to do |format|
      format.json {
        render :json => JSON.generate(@raw_result), :content_type => "application/json"
      }
    end
    
  end  
  
  protected
  
  def client
    if params[:session_api].blank? and params[:id].blank?
      return OAuth2::Client.new(FOURSQUARE_KEY, FOURSQUARE_SECRET, :site => 'https://www.foursquare.com')
    else
      client = Foursquare2::Client.new(:oauth_token => current_user.foursquare_token)
    end    
  end  
end
