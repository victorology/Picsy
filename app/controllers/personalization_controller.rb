# -*- encoding : utf-8 -*-
class PersonalizationController < ApplicationController
  before_filter :authenticate_user!, :except => [:user_creation, :sub_categories, :new_user, :user_sign_in, :ajax_user_creation]
  before_filter :convert_api_params, :only => [:user_creation]
  protect_from_forgery :except => [:user_creation]
  

  def user_creation
    @user = User.new(params[:user])

    if @user.valid?
      @user.language = params[:language] unless params[:language].blank?
      @user.save
      sign_in @user
      @user.update_session_api if params[:format] == "json"
      @registered_user = {
        :id => @user.id,
        :nickname => @user.nickname,
        :email => @user.email,
        :session_api => @user.session_api
      }
      @result = true
    else
      @result = false  
    end
    
    
    if @result == true
      flash[:notice] = t("thank you for signing up")
	  else
      flash[:user_creation_fail_notice] = t("failed to register due to")+": #{@user.errors.full_messages.join(', ')}"
	  end	  
	  
	  respond_to do |format|
	    format.json {     
	      @raw_result = {
          :code => (@result == true) ? 0 : 1,
          :error_message => (@result == true) ?  nil : flash[:user_creation_fail_notice] ,
          :value => {
            :registered_user => @registered_user
          }
        }
        render :json => JSON.generate(@raw_result), :content_type => Mime::JSON
	    }
	    format.html {
	      redirect_to my_path if @result == true
	    }
	  end  
  end
  
  
  protected
  
  ### convert params that come from API, this will be used by iPhone/Android app
  def convert_api_params
    params[:chk_categeory] = params[:categories].split(",") unless params[:categories].blank?
    parans[:chk_location] = params[:locations].split(",") unless params[:locations].blank?
  end  

  
end
