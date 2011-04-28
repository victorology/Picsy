require 'pp'

class TumblrController < ApplicationController
  protect_from_forgery :except => [:connect]
  before_filter :authenticate_user!
  
  def connect
    #@user = User.where("tumblr_email = ? AND tumblr_key",params[:tumblr_email],User.stumblr_key_encrypt(params[:tumblr_password])
    body = {
      :email => params[:tumblr_email],
      :password => params[:tumblr_password]
    }
    clnt = HTTPClient.new
    response = clnt.post("http://www.tumblr.com/api/authenticate",body)
    
    Rails.logger.info "TUMBLR RESPONSE : \n #{pp response.body}"
=begin    
    success example
    <?xml version="1.0" encoding="UTF-8"?>
    <tumblr version="1.0">
      <user default-post-format="html" can-upload-audio="1" can-upload-aiff="1" can-ask-question="1" can-upload-video="1" max-video-bytes-uploaded="26214400" liked-post-count="0"/>
      <tumblelog title="test ajah" is-admin="1" posts="0" twitter-enabled="0" draft-count="0" messages-count="0" queue-count="" name="aditkircon" url="http://aditkircon.tumblr.com/" type="public" followers="0" avatar-url="http://27.media.tumblr.com/avatar_f11f4019dcee_128.png" is-primary="yes" backup-post-limit="30000"/>
    </tumblr>
=end    
 

    @user = User.where("tumblr_email = ? AND id != ?",params[:tumbr_email],current_user.id).first
    
    if params[:tumblr_email].blank?
      @raw_result = {
        :code => 1,
        :error_message => "can't register with blank email",
        :value => nil
      }
    elsif @user.nil? == false
      @raw_result = {
        :code => 1,
        :error_message => "this tumblr email has already been taken by other user",
        :value => nil
      }   
    elsif response.body.include?("Invalid credentials")
      @raw_result = {
        :code => 1,
        :error_message => "Invalid credentials",
        :value => nil
      }
    else    
      ### success
      doc = Nokogiri::XML response.body

      rs = current_user.update_attributes(
        :tumblr_email => params[:tumblr_email],
        :tumblr_secret => User.tumblr_pwd_encrypt(params[:tumblr_password]),
        :tumblr_nickname => doc.xpath("//tumblr//tumblelog")[0].attr('name')
      )
        
      @raw_result = {
        :code => 0,
        :error_message => nil,
        :value => {
          :is_tumblr_connected => true
        } 
      }  
    end    
    
    render :text => JSON.generate(@raw_result), :content_type => "application/json"
  end  
end
