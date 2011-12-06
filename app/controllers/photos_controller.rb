# -*- encoding : utf-8 -*-

class PhotosController < ApplicationController
  include ActionView::Helpers::TextHelper 
  
  before_filter :authenticate_user!, :except => [:show, :shortened, :regenerate]
  protect_from_forgery :except => [:create, :mine]
  
  def shortened
    @photo = Photo.find(:first, :conditions => {:code => params[:code]})
    redirect_to @photo.page_path
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
            :error_message => t("you don't have any uploaded photos"),
            :value => nil
          }
        end    

        render :json => JSON.generate(@raw_result), :content_type => Mime::JSON
      }
    end

  end  

  def feed
    if @api_user.following.blank?
      @msg = t("you have to follow at least one user to see a feed of photos")
    else
      @photos = @api_user.get_following_photos
      if @photos.blank?
        @msg = t("users that you follow don't have any uploaded photos yet")
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
          #@photo.cyworld
          #upload photo to social networks
          Resque.enqueue(PhotoJob, @photo.id, "http://"+request.host_with_port)
          
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
          msg += t("some photos can't be regenerated")+" <br />" if i == 0
          msg += t("id")+" : #{err[:id]} <br />"
          msg += t("error messages")+" : #{err[:message]}<br />"
          msg += t("owner")+" : #{err[:owner]} <br /><hr />"
        end  
      else  
        msg = t("photo has been regenerated successfully")
      end  
    else
      msg = t("you don't have privilege to access this page")
    end     
    render :text => msg, :layout => false
  end
  
  protected
  def photo_hash(photo, show_owner = false)
    photo.host_with_port = "http://"+request.host_with_port
    rs = {
      :title => photo.title,
      :filter => photo.filter,
      :original_width => photo.width,
      :original_height => photo.height,
      :shortened_url => photo.shortened_url,
      :page_url => "http://"+request.host_with_port+photo.page_path,
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
    
    rs.merge!(fb_hash) if photo.post_to_facebook == "yes" || (photo.post_to_facebook_album == "yes" and !photo.fb_album_name.blank?) || photo.post_to_facebook_wall == "yes"
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

  def url_escape(url)
    url_arr = url.split("/")
    url_arr[5] = URI.escape(url_arr[5])
    url_arr[8] = URI.escape(url_arr[8])
    return url_arr.join("/")
  end  
  
end
