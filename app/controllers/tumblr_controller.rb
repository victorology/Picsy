# -*- encoding : utf-8 -*-

class TumblrController < ApplicationController
  protect_from_forgery :except => [:connect]
  before_filter :authenticate_user!
  
  def connect
    body = {
      :email => params[:tumblr_email],
      :password => params[:tumblr_password]
    }
    clnt = HTTPClient.new
    response = clnt.post("http://www.tumblr.com/api/authenticate",body)
    
    Rails.logger.info "TUMBLR RESPONSE : \n #{pp response.body}"
  
    @user = User.where("tumblr_email = ? AND id != ?",params[:tumbr_email],current_user.id).first
    
    if params[:tumblr_email].blank?
      @raw_result = {
        :code => 1,
        :error_message => t("can't register with blank email"),
        :value => nil
      }
    elsif @user.nil? == false
      @raw_result = {
        :code => 1,
        :error_message => t("this tumblr email has already been taken by other user"),
        :value => nil
      }   
    elsif response.body.include?("invalid credentials")
      @raw_result = {
        :code => 1,
        :error_message => t("invalid credentials"),
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
  
  def unlink
    current_user.update_attributes(:tumblr_secret => nil, :tumblr_nickname => nil)
    respond_to do |format|
      format.html {
        flash[:notice] = t("your account has been unlinked from tumblr successfully")
        redirect_to connections_path
      }
      format.json {
        @raw_result = {
          :code => 0,
          :error_message => nil,
          :value => {
            :tumblr => {
              :unlink => current_user.facebook_connected? ? t("failed") : t("success")
            },
          }
        }
        render :json => JSON.generate(@raw_result)    
      }  
    end
  end  
end
