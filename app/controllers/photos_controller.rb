# -*- encoding : utf-8 -*-
class PhotosController < ApplicationController
  include ActionView::Helpers::TextHelper 
  
  before_filter :authenticate_user!, :except => [:show, :shortened, :regenerate]
  protect_from_forgery :except => [:create, :mine]
  
  def shortened
    @photo = Photo.find(:first, :conditions => {:code => params[:code]})
    redirect_to photo_page_path(@photo)
  end  
  
  def show
    # this code probably should be used later, need Victor confirmation
    #if params[:code]
    #  @reference_id = Invite.where(:guid => params[:code]).first.id
    #end
    
    @invite = Invite.new
    @photo = Photo.find(:first, :conditions => ["photos.code = ? AND users.nickname = ?",params[:code], params[:nickname]], :include => :user)
    render :layout => "photo"
  end  
  
  def mine
    respond_to do |format|
      format.json {
        @photos = current_user.try(:photos)
        if @photos.size > 0          
          @raw_result = {
            :code => 0,
            :error_message => nil,
            :value => @photos.reverse.collect {|photo| photo_hash photo}
          }
        else
          @raw_result = {
            :code => 1,
            :error_message => "you don't have any uploaded photos",
            :value => nil
          }
        end    

        render :json => JSON.generate(@raw_result), :content_type => Mime::JSON
      }
    end

  end  

  def feed
    if @api_user.following.blank?
      @msg = "You have to follow at least one user to see a feed of photos"
    else
      @photos = @api_user.get_following_photos
      if @photos.blank?
        @msg = "Users that you follow don't have any uploaded photos yet"
      end
    end

    @raw_result = {
      :code => (@msg.blank?) ? 1 : 0,
      :error_message => @msg,
      :value => {
        :photos  => @photos.blank? ? nil : @photos.collect {|photo| photo_hash photo, true}
      }
    }

   respond_to do |format|
      format.json {
        render :json => JSON.generate(@raw_result), :content_type => Mime::JSON
      }  
    end 
  end
  
  def create

    respond_to do |format|
      format.json {
        @photo = Photo.new(params[:photo])
        @photo.user_id = current_user.id
        @photo.host_with_port = "http://"+request.host_with_port
        
        if @photo.save
          
          ### twitter upload, it's supposed to be put in the model
          ### however it's difficult to create photo url in there 
          ### so i put twitter upload photo at here
          if @photo.user.twitter_connected? == true and params[:photo][:post_to_twitter] == "yes"
            client = TwitterOAuth::Client.new(
                :consumer_key => TWITTER_CONSUMER_KEY,
                :consumer_secret => TWITTER_CONSUMER_SECRET,
                :token => @photo.user.twitter_token, 
                :secret => @photo.user.twitter_secret
            )

            client.update("#{truncate(@photo.title, :length => 120)} #{shortened_url(@photo)}")  
          end
      
          if @photo.user.me2day_connected? == true and params[:photo][:post_to_me2day] == "yes"
            @client = Me2day::Client.new(
              :user_id => @photo.user.me2day_id, :user_key => @photo.user.me2day_key, :app_key => ME2DAY_KEY
            )      

            if JSON.parse(@client.noop)["code"].to_s == "0" #"성공했습니다."
              result = @client.create_post @photo.user.me2day_nickname, 'post[body]' => "#{truncate(@photo.title, :length => 120)} #{shortened_url(@photo)}", 'attachment' => File.open(Rails.root.to_s+"/public"+@photo.image.url.gsub("?")[0])
              
              Rails.logger.info "POST RESULT #{result.inspect}"
            end  
          end  

          if @photo.user.facebook_connected? == true and @photo.post_to_facebook_wall == "yes"
            clnt = HTTPClient.new

            body = {:access_token => @photo.user.facebook_token, :link => photo_hash(@photo)[:page_url], 
                    :picture => photo_hash(@photo)[:original_url], :name => @photo.title} 
            response = clnt.post("https://graph.facebook.com/#{@photo.user.facebook_id}/feed", body)

            fbid = JSON.parse(response.content)["id"].split("_")[1]
            id = JSON.parse(response.content)["id"].split("_")[0]
            @photo.update_attribute(:fb_wall_url, "http://facebook.com/permalink.php?story_fbid=#{fbid}&id=#{id}")     
          end
          
          @raw_result = {
            :code => 0,
            :error_message => nil,
            :value => {
              :photo => photo_hash(@photo)
            }
          }
        else
          @raw_result = {
            :code => 1,
            :error_message => "#{@photo.errors.full_messages.join('<br />')}",
            :value => nil
          }  
        end    
             
        render :json => JSON.generate(@raw_result), :content_type => Mime::JSON
      }
    end  
  end  
  
  # http://localhost:3301/photos/7c997030852f012e367e00254ba34756/regenerate
  def regenerate
    msg = ""
    if params[:id].to_s == GENERATE_PHOTO_KEY
      err_arr = Photo.regenerate
      if err_arr.size > 0
        err_arr.each_with_index do |err,i|
          msg += "some photo can't be regenerated <br />" if i == 0
          msg += "id : #{err[:id]} <br />"
          msg += "error message : #{err[:message]}<br />"
          msg += "owner : #{err[:owner]} <br /><hr />"
        end  
      else  
        msg = "photo has been regenerated successfully"
      end  
    else
      msg = "You don't have privilege to access this page"
    end     
    render :text => msg, :layout => false
  end
  
  protected
  def photo_hash(photo, show_owner = false)
    rs = {
      :title => photo.title,
      :filter => photo.filter,
      :original_width => photo.width,
      :original_height => photo.height,
      :shortened_url => shortened_url(photo),
      :page_url => "http://"+request.host_with_port+photo_page_path(photo),
    }  
   
    photo_url_hash = {
      :thumbnail_url => url_escape("http://"+request.host_with_port+photo.image.url(:medium)),
      :thumbnail_url_retina => url_escape("http://"+request.host_with_port+photo.image.url(:retina)),
      :original_url => url_escape("http://"+request.host_with_port+photo.image.url),
    }
    
    ## additional value
    fb_hash = {
      :fb_wall_url => photo.fb_wall_url,
      :fb_original_url => photo.fb_original_url,
      :fb_thumbnail_url => photo.fb_thumbnail_url
    }
    
    rs.merge!(fb_hash) if photo.post_to_facebook == "yes" || (photo.post_to_facebook_album == "yes" and !photo.album_name.blank?) || photo.post_to_facebook_wall == "yes"
    rs.merge!(photo_url_hash)  

    if show_owner
      owner = photo.user
      owner_hash = {
        :owner_id => owner.id,
        :owner_nickname => owner.nickname,
      }
      rs.merge!(owner_hash)  
    end
      
    return rs 
  end

  def shortened_url(photo)
    return ("http://"+request.host_with_port+"/#{prefix_rand}#{photo.code}").gsub("www.","")
  end  
  
  def prefix_rand
    if @prefix_rand.blank?
      prefix = ["z","t","q","x"]
      @prefix_rand = prefix[rand(prefix.size)]
    end
    return @prefix_rand  
  end  
    
  def photo_page_path(photo)
    "/photo/#{URI.escape(photo.user.nickname)}/#{prefix_rand}#{photo.code}"
  end
  
  def url_escape(url)
    url_arr = url.split("/")
    url_arr[5] = URI.escape(url_arr[5])
    url_arr[8] = URI.escape(url_arr[8])
    return url_arr.join("/")
  end  
    
end
