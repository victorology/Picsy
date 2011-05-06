# -*- encoding : utf-8 -*-
class UsersController < ApplicationController
  before_filter :authenticate_user!
  layout 'launch'

  def index
    @user = User.all
  end

  def edit
    @user = User.find(params[:id])
    if current_user.id != @user.id
      flash[:notice] = "it's not yours "
      redirect_to users_path
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = 'success edit user.'
      redirect_to users_path
    else
      flash[:notice] = 'failed edit user'
      redirect_to users_path
    end
  end
end
