# -*- encoding : utf-8 -*-
class Photo < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  belongs_to :user
  
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h, :host_with_port
  has_attached_file :image, 
    :styles => { :medium => "100x100#", :retina => "200x200#"}, 
    :url => "/system/uphotos/:pattern_nickname/:pattern_code/:style/:basename.:extension"
  
  validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/jpg', 'image/png','image/gif'], :message => :content_type_invalid
  validates_attachment_presence :image, :message => :blank
  validates_attachment_size :image, :less_than => 100.megabytes
  validates_presence_of :filter
  
  before_create :check_filter, :generate_code, :check_post_to
  
  def generate_code
    charset = %w{1 2 3 4 6 7 9 A C D E F G H J K L M N P Q R T V W X Y Z}
    rs = (0...2).map{ charset.to_a[rand(charset.size)] }.join
    last = Photo.find(:all, :order => "id").last
    last_id = (last.nil?) ? 1 : last.id + 1 
    rs = rs.insert(2,last_id.to_s(36)).downcase
    if Photo.count(:conditions => {:code => rs}) > 0
      generate_code
    else        
      self.code = rs
    end  
    return rs
  end 
  
  def tumblr_photo
    
    if self.user.tumblr_connected? == true and self.post_to_tumblr == "yes"
      body = {
        :email => self.user.tumblr_email,
        :password => User.tumblr_pwd_decrypt(self.user.tumblr_secret),
        :type => "photo",
        :caption => "#{self.title} taken with PUMPL "+self.shortened_url,
        :data => File.open(self.image.path) 
      }
      clnt = HTTPClient.new
      response = clnt.post("http://www.tumblr.com/api/write",body)
      
      unless response.status == 201
        errors[:base] << "Bad request, most likely your image is larger than 10 MB or connection timeout"
        return false
      end
    elsif self.user.tumblr_connected? == false and self.post_to_tumblr == "yes"
      errors[:base] << "Can't post photo to tumblr, you need to link your account first"  
      return false  
    end  
    
  end  
  
  def fb_photo
    
    if self.user.facebook_connected? == true and self.post_to_facebook == "yes"   
      
      clnt = HTTPClient.new
      
      #obtain fb album id      
      album_response = clnt.get("https://graph.facebook.com/me/albums", {:access_token => self.user.facebook_token})
      
      JSON.parse(album_response.body)["data"].each do |album|
        if album["name"] == FB_ALBUM_NAME
          @album_id = album["id"]
          break
        end  
      end  
      
      if @album_id.blank?
        album_response = clnt.post("https://graph.facebook.com/me/albums",{:access_token => self.user.facebook_token, :name => FB_ALBUM_NAME})
        @album_id = JSON.parse(album_response.body)["id"]
      end  
      
      ## post photo to facebook
      source = File.open(self.image.path)
      
      body = {:access_token => self.user.facebook_token, :source => source,:message => "#{self.title} taken with PUMPL "+self.shortened_url}
      
      response = clnt.post("https://graph.facebook.com/#{@album_id}/photos",body)
     
      c = Curl::Easy.perform("https://graph.facebook.com/#{JSON.parse(response.content)['id']}/?access_token=#{self.user.facebook_token}")
      rs = JSON.parse(c.body_str)
      
      if rs["error"]
        if rs["error"]["message"].include?("Error validating access token")
          self.user.update_attributes(:facebook_token => nil, :facebook_nickname => nil)
          errors[:base] << "this user account isn't connected to Facebook, please authorize it first"
        else
          errors[:base] << rs["error"]["message"]
        end    
        return false
      else  
        self.update_attributes(:fb_original_url => rs["source"], :fb_thumbnail_url => rs["picture"])
      end  
    
    elsif self.user.facebook_connected? == false and self.post_to_facebook == "yes" 
      errors[:base] << "Can't post photo to facebook, you need to link your account first" 
      return false
    end  
  end  

  def fb_photo_to_album
    if self.user.facebook_connected? == true and self.post_to_facebook_album == "yes" and !self.fb_album_name.blank?
      @album_id = self.user.find_or_create_by_facebook_album(self.fb_album_name)

      ## post photo to facebook
      clnt = HTTPClient.new      
      source = File.open(self.image.path)
      body = {:access_token => self.user.facebook_token, :source => source,:message => "#{self.title} taken with PUMPL "+self.shortened_url}
      response = clnt.post("https://graph.facebook.com/#{@album_id}/photos",body)
     
      c = Curl::Easy.perform("https://graph.facebook.com/#{JSON.parse(response.content)['id']}/?access_token=#{self.user.facebook_token}")
      rs = JSON.parse(c.body_str)
      
      if rs["error"]
        if rs["error"]["message"].include?("Error validating access token")
          self.user.update_attributes(:facebook_token => nil, :facebook_nickname => nil, :facebook_id => nil)
          errors[:base] << "this user account isn't connected to Facebook, please authorize it first"
        else
          errors[:base] << rs["error"]["message"]
        end    
        return false
      else  
        self.update_attributes(:fb_original_url => rs["source"], :fb_thumbnail_url => rs["picture"])
      end  
    elsif self.user.facebook_connected? == false and self.post_to_facebook_album == "yes" and !self.album_name.blank?
      errors[:base] << "Can't post photo to facebook, you need to link your account first" 
      return false
    end  
  end

  def fb_wall
    if self.user.facebook_connected? == true and self.post_to_facebook_wall == "yes"
      clnt = HTTPClient.new

      body = {:access_token => self.user.facebook_token, :link => self.host_with_port+self.page_path, 
              :picture => self.host_with_port+self.image.url, :name => self.title} 
      response = clnt.post("https://graph.facebook.com/#{self.user.facebook_id}/feed", body)

      fbid = JSON.parse(response.content)["id"].split("_")[1]
      id = JSON.parse(response.content)["id"].split("_")[0]
      self.update_attribute(:fb_wall_url, "http://facebook.com/permalink.php?story_fbid=#{fbid}&id=#{id}")     
    end
  end

  def twitter
    if self.user.twitter_connected? == true and self.post_to_twitter == "yes"
      client = TwitterOAuth::Client.new(
                :consumer_key => TWITTER_CONSUMER_KEY,
                :consumer_secret => TWITTER_CONSUMER_SECRET,
                :token => self.user.twitter_token, 
                :secret => self.user.twitter_secret
               )

      client.update("#{truncate(self.title, :length => 120)} #{self.shortened_url}")  
    end
  end

  def me2day
   if self.user.me2day_connected? == true and self.post_to_me2day == "yes"
      @client = Me2day::Client.new(
        :user_id => self.user.me2day_id, :user_key => self.user.me2day_key, :app_key => ME2DAY_KEY
      )      

      if JSON.parse(@client.noop)["code"].to_s == "0" #"성공했습니다."
        clnt = HTTPClient.new
              
        File.open(Rails.root.to_s+"/public"+self.image.url.split("?")[0]) do |file|
          nonce = rand(0xffffffff).to_s(16)
          u_key = nonce + Digest::MD5.hexdigest(nonce + self.user.me2day_key)

          body = { 
            'content_type' => "photo",
            'attachment' => file,  
            'post[body]' => "#{truncate(self.title, :length => 120)} #{self.shortened_url}",
            'uid'=> self.user.me2day_id,
            'ukey' => u_key
          }
                
          post_uri = "http://me2day.net/api/create_post/#{self.user.me2day_id}.json"
          result = clnt.post(post_uri, body, 'me2_application_key' => ME2DAY_KEY)
          Rails.logger.info "POST RESULT #{result.body.inspect}"
        end
=begin              
        Rails.logger.info "ME2DAY NICKNAME #{self.user.me2day_nickname} \n"      
        Rails.logger.info "STARTING TO GET POSTs"
              
        posts = @client.get_posts(self.user.me2day_id)
        Rails.logger.info "GRAB POSTS #{posts.inspect} \n"
              
        photo_path = Rails.root.to_s+"/public"+self.image.url.split("?")[0]
        Rails.logger.info "PHOTO PATH #{photo_path} \n"
              
        result = @client.create_post @photo.user.me2day_id, 'post[body]' => "#{truncate(self.title, :length => 120)} #{self.shortened_url}", 'attachment' => File.new(photo_path)

        Rails.logger.info "POST RESULT #{result.inspect}}"
=end              
      end  
    end 
  end
  
  ## options[:thumbnail]
  
  def true_image_url(options = {})
    #if self.fb_original_url.blank?
      return options[:thumbnail] == true ? self.image.url(:medium) : self.image.url
    #else
    #  return options[:thumbnail] == true ? self.fb_thumbnail_url : self.fb_original_url
    #end    
  end  
  
  def pattern_code
    "#{self.code}"
  end
  
  def pattern_nickname
    "#{self.user.nickname}"
  end  
  
  def width
    dimension("width")
  end
  
  def height
    dimension("height")
  end    
  
  def cropping?  
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?  
  end
  
  def self.regenerate
    error_arr = []
    self.all.each do |photo|
      #cl_photo = photo.clone
      #cl_photo.save
      
      path = Rails.root.to_s+"/public"+photo.image.url
      Rails.logger.info "IMAGE PATH #{path}"
      if File.exist?(path)
        rs = photo.update_attribute(:image,File.open(path))
        
        if rs == false
          error_arr << {
            :id => photo.id,
            :message => photo.errors.full_messages.join(','),
            :owner => photo.user.nickname
          }
        end    
      else
        error_arr << {
          :id => photo.id,
          :message => "Original image isn't exist",
          :owner => photo.user.nickname
        }  
      end
  
    end
    return error_arr  
  end  

  def page_path
    "/photo/#{URI.escape(self.user.nickname)}/#{prefix_rand}#{self.code}"
  end

  def shortened_url    
    return (self.host_with_port+"/#{prefix_rand}#{self.code}").gsub("www.","")
  end

  alias_method :old_save, :save
  def save(options={})
    resave(options, 1)   
  end

  def resave(options, attempts)
    begin 
      old_save(options)
    rescue
      attempts += 1
      if attempts <= 3
        resave(options, attempts)
      end    
    end
  end

  def self.delete_unowned_photos
    Photo.delete_all("photos.user_id NOT IN (SELECT id FROM users)") 
  end
    
  protected 
  
  def check_filter
    if PHOTOS_FILTER.include?(self.filter)
      return true
    else
      errors[:base] << "filter is invalid"
      return false
    end    
  end
  
  def reprocess_image 
    image.reprocess!  
  end
  
  def check_post_to
    ["facebook","twitter","tumblr"].each do |svc|
      write_attribute("post_to_#{svc}".to_sym,"no") if read_attribute("post_to_#{svc}".to_sym) != "yes"
    end  
  end  
  
  def dimension(type)
    if self.send("image_#{type}").blank?
      image_path = Rails.root.to_s+"/public"+self.image.url.split("?")[0]
      if File.exists?(image_path)
        image = MiniMagick::Image.open(image_path)
        self.update_attribute("image_#{type}".to_sym,image["#{type}".to_sym])
      end  
    end
    return self.send("image_#{type}").try(:to_s)
  end  
  
  def prefix_rand
    if @prefix_rand.blank?
      prefix = ["z","t","q","x"]
      @prefix_rand = prefix[rand(prefix.size)]
    end
    return @prefix_rand 
  end
  
  def url_escape(url)
    url_arr = url.split("/")
    url_arr[5] = URI.escape(url_arr[5])
    url_arr[8] = URI.escape(url_arr[8])
    return url_arr.join("/")
  end  
  
end
