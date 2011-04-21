class LaunchController < ApplicationController
  layout "launch"
  
  def index
    
    ### ceck cookies
    @invite = Invite.where(:guid => cookies[:guid]).first
    if @invite.nil?
      @invite = Invite.new
    else
      render :action => :thank_you
    end    
  end
  
  def invite
    
    @invite = Invite.new(params[:invite])
    
    if @invite.save
      @invite.reload
      cookies.permanent[:guid] = @invite.guid
      redirect_to thank_you_launch_index_path
    else
      render :action => :index
    end    
  end    
  
  def thank_you
  end  
end
