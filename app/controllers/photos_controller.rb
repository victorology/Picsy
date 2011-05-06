# -*- encoding : utf-8 -*-
class PhotosController < ApplicationController
  include ActionView::Helpers::TextHelper 
  
  before_filter :authenticate_user!, :except => [:show, :shortened]
  protect_from_forgery :except => [:create, :mine]
  
  def shortened
    @photo = Photo.find(:first, :conditions => {:code => params[:code]})
    redirect_to photo_page_path(@photo)
  end  
  
  def show
    @photo = Photo.find(:first, :conditions => ["photos.code = ? AND users.nickname = ?",params[:code], params[:nickname]], :include => :user)
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
  
  def create

    respond_to do |format|
      format.json {
        @photo = Photo.new(params[:photo])
        @photo.user_id = current_user.id
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
  
  protected
  def photo_hash(photo)
    rs = {
      :title => photo.title,
      :original_width => photo.width,
      :original_height => photo.height,
      :shortened_url => shortened_url(photo),
      :page_url => "http://"+request.host_with_port+photo_page_path(photo),
    }  
   
    photo_url_hash = {
      :thumbnail_url => "http://"+request.host_with_port+photo.image.url(:medium),
      :original_url =>  "http://"+request.host_with_port+photo.image.url,
    }
      
    return rs.merge(photo_url_hash)  
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
    "/photo/#{photo.user.nickname}/#{prefix_rand}#{photo.code}"
  end
  
end
