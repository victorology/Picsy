class LaunchController < ApplicationController
  layout "launch"
  
  def index
    @invite = Invite.new
  end
  
  def invite
    
    @invite = Invite.new(params[:invite])
    
    if @invite.save
      @invite.reload
      cookies.permanent[:guid] = @invite.guid
      redirect_to thank_you_launch_index_path
    else
      render :index
    end    
  end    
  
  def thank_you
  end  
end
