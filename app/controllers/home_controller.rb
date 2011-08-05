# -*- encoding : utf-8 -*-
class HomeController < ApplicationController
  
  def index
    render :text => "Picsy"
  end 
  
  def welcome
    if current_user
      redirect_to my_path
    else
      redirect_to "/"
    end    
  end     
end
