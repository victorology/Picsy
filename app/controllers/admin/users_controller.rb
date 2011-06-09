# -*- encoding : utf-8 -*-
class Admin::UsersController < ApplicationController
  before_filter :authenticate_user!
  layout "admin"
  
  def index
    @users = User.all
  end  
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:message] = "User was successfully created"
      redirect_to :action => "index"
    else
      render :action => "new"
    end
  end
  
  def multiple_destroy
    if params[:user_ids]
      User.destroy_all(["id IN (?)", params[:user_ids]])
      flash[:message] = "User(s) was successfully deleted"
    else
      flash[:message] = "Please choose at least one user"
    end
    redirect_to :action => "index"
  end
  
end
