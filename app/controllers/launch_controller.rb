# -*- encoding : utf-8 -*-
class LaunchController < ApplicationController
  layout "launch"
  
  def index    
    # me2day confirm
    if params[:token]
      redirect_to confirm_me2day_index_path(
        :token => params[:token],
        :result => params[:result],
        :user_id => params[:user_id],
        :user_key => params[:user_key]
      )
    else  
    
      if params[:code]
        @reference_id = Invite.where(:guid => params[:code]).first.id
      end  
    
      # facebook confirm
      #if params[:code]
      #  redirect_to confirm_facebook_index_path(:code => params[:code])
      #end 
    
      ### check cookies
      @invite = Invite.where(:guid => cookies[:guid]).first
      if @invite.nil?
        @invite = Invite.new
        render :layout => false
      else
        Rails.logger.info "INVITE EMAIL #{@invite.email}"
        render :action => :thank_you
      end
    end      
  end
  
  def invite
    @invite = Invite.where(:email => params[:invite][:email]).first
    
    if @invite.nil?
      @invite = Invite.new(params[:invite])
    
      if @invite.save
        @invite.reload
        cookies.permanent[:guid] = @invite.guid
        redirect_to thank_you_launch_index_path
      else
        render :action => :index, :layout => false
      end    
    else
      cookies.permanent[:guid] = @invite.guid
      redirect_to thank_you_launch_index_path
    end    
  end    
  
  def thank_you
    @invite = Invite.where(:guid => cookies[:guid]).first
  end  
end
