# -*- encoding : utf-8 -*-
class UsersController < ApplicationController
  before_filter :authenticate_user!
  layout 'launch'

  def index
    @user = User.all
  end

  #def edit_profile
  #  @user = User.find(params[:id])
  #  if current_user.id != @user.id
  #    flash[:notice] = "it's not yours "
  #    redirect_to users_path
  #  end
  #end

  def update_profile
    params[:user] = {
      :nickname => params[:nickname],
      :email => params[:email],
      :phone_number => params[:phone_number]
    }
    
    #@user = User.find(params[:id])
    if @api_user.update_attributes(params[:user])
      code = 1
      error_message = nil
      user_data = {
        :nickname => @api_user.nickname,
        :email => @api_user.email,
        :phone_number => @api_user.phone_number
      }
    else
      code = 0
      error_message = @api_user.errors.full_messages.join(", ")
      user_data = nil
    end  
    
    @raw_result = {
      :code => code,
      :error_message => error_message,
      :value => {
        :user => user_data
      }
    }
    
    respond_to do |format|
      format.json {
        render :json => JSON.generate(@raw_result), :content_type => Mime::JSON
      }  
    end
  end
  
  def update_profile_photo
    
    @api_user.profile_photo = params[:profile_photo]
    if params[:profile_photo].blank?
      @msg = t("profile photo can't be blank")
    elsif @api_user.save
      @photo_url = "http://#{request.host_with_port}#{@api_user.profile_photo.url}"
    else
      @msg = @api_user.errors.full_messages.join(",")
    end  
    
    @raw_result = {
      :code => (@msg.blank?) ? 1 : 0,
      :error_message => @msg,
      :value => {
        :url => @photo_url
      }
    }
    
    respond_to do |format|
      format.json {
        render :json => JSON.generate(@raw_result), :content_type => Mime::JSON
      }  
    end   
       
  end 

  def follow
    if @api_user.id == params[:following_id].to_i
      @msg = "can't follow yourself"
    else
      @user_following = @api_user.user_following.find_or_initialize_by_following_id(params[:following_id])
      unless @user_following.save
        @msg = @user_following.errors.full_messages.join(". ")
      end
    end

    @raw_result = {
      :code => (@msg.blank?) ? 1 : 0,
      :error_message => @msg,
      :value => {
        :total_following => "#{@api_user.following.size} user(s)" ,
        :following_ids => @api_user.following.collect(&:id).join(",")
      }
    }
    
    respond_to do |format|
      format.json {
        render :json => JSON.generate(@raw_result), :content_type => Mime::JSON
      }  
    end   
  end

  def unfollow
    @user_following  = @api_user.user_following.find_by_following_id(params[:following_id])
    if @user_following 
      unless @user_following.destroy
        @msg = t("unfollow failed")+" : #{@user_following.errors.full_messsages.join(". ")}"
      end 
    else
      @msg = t("you only can unfollow user that already followed")
    end

    @raw_result = {
      :code => (@msg.blank?) ? 1 : 0,
      :error_message => @msg,
      :value => {
        :total_following  => "#{@api_user.following.size}",
        :following_ids => @api_user.following.collect(&:id).join(",")
      }
    }

    respond_to do |format|
      format.json {
        render :json => JSON.generate(@raw_result), :content_type => Mime::JSON
      }  
    end  
  end 

  def following_and_followers_list 
    @raw_result = {
      :code => 1,
      :error_message => nil,
      :value => {
        :following  => @api_user.following.collect{|user| user_hash user},
        :followers => @api_user.followers.collect{|user| user_hash user}
      }
    }

    respond_to do |format|
      format.json {
        render :json => JSON.generate(@raw_result), :content_type => Mime::JSON
      }  
    end  
  end

  def find_friends
    @following_ids = @api_user.following.collect(&:id)
    @friends = User.where("id NOT in (?)", @following_ids)

    #find facebook friends
    facebook_status, facebook_data = @api_user.facebook_friends
    if facebook_status
      @facebook_friend_ids = facebook_data.empty? ? [] : facebook_data.map{|k| k['id']}
      @facebook_friends = @friends.where("facebook_id in (?)", @facebook_friend_ids)
    else
      @facebook_msg = facebook_data
      @facebook_friends  = []
    end

    #find twitter friend ids
    twitter_status, twitter_data = @api_user.twitter_friend_ids
    if twitter_status
      @twitter_friend_ids = twitter_data
      @twitter_friends = @friends.where("twitter_id in (?)", @twitter_friend_ids)
    else
      @twitter_msg = twitter_data
      @twitter_friends  = []
    end

    unless facebook_status || twitter_status
      @msg = [@facebook_msg, @twitter_msg].join(". ")
    end

    @raw_result = {
      :code => (@msg.blank?) ? 1 : 0,
      :error_message => @msg,
      :value => { 
        :facebook_friends => @facebook_friends.collect{|user| user_hash user},
        :twitter_friends => @twitter_friends.collect{|user| user_hash user}
      }
    }

    respond_to do |format|
      format.json {
        render :json => JSON.generate(@raw_result), :content_type => Mime::JSON
      }  
    end  
  end

  protected
  def user_hash(user)
    rs = {
      :id => user.id,
      :nickname => user.nickname,
      :email => user.email
    }

    return rs  
  end

end
