class Photo < ActiveRecord::Base
  belongs_to :user
  
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h, :post_to_facebook, :post_to_twitter, :post_to_tumblr
  has_attached_file :image, 
    :styles => { :medium => "75x100#"}, 
    :url => "/system/uphotos/:pattern_nickname/:pattern_code/:style/:basename.:extension"
  
  validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/jpg', 'image/png','image/gif']
  validates_attachment_presence :image
  validates_attachment_size :image, :less_than => 100.megabytes
  
  before_create :generate_code, :check_post_to
  before_create :fb_photo, :tumblr_photo
      
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
        :caption => self.title,
        :data => File.open(self.image.queued_for_write[:original].path) 
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
      #curl -F 'access_token=...' \
      #     -F 'source=@file.png' \
      #     -F 'message=Caption for the photo' \
      #     https://graph.facebook.com/me/photos
      
      clnt = HTTPClient.new
      source = File.open(self.image.queued_for_write[:original].path)
      body = {:access_token => self.user.facebook_token, :source => source,:message => self.title}
      response = clnt.post("https://graph.facebook.com/me/photos",body)
     
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
        write_attribute(:fb_original_url,rs["source"])
        write_attribute(:fb_thumbnail_url,rs["picture"])
      end  
    
    elsif self.user.facebook_connected? == false and self.post_to_facebook == "yes" 
      errors[:base] << "Can't post photo to facebook, you need to link your account first" 
      return false
    end  
  end  
  
  ## options[:thumbnail]
  
  def true_image_url(options = {})
    if self.fb_original_url.blank?
      return options[:thumbnail] == true ? self.image.url(:medium) : self.image.url
    else
      return options[:thumbnail] == true ? self.fb_thumbnail_url : self.fb_original_url
    end    
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
  
  protected 
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
  
    

end
