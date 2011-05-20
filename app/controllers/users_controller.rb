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
    
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      code = 1
      error_message = nil
      user_data = {
        :nickname => @user.nickname,
        :email => @user.email,
        :phone_number => @user.phone_number
      }
    else
      code = 0
      error_message = @user.errors.full_messages.join(", ")
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
  
end
