class Devise::PasswordsController < ApplicationController
  prepend_before_filter :require_no_authentication
  skip_before_filter :protect_from_forgery
  
  include Devise::Controllers::InternalHelpers

  # GET /resource/password/new
  def new
    build_resource({})
    render_with_scope :new
  end

  # POST /resource/password
  def create
    ## check nickname
    unless params[resource_name][:email].include?("@")
      pre_resource = resource_class.where(:nickname => params[resource_name][:email]).first 
      params[resource_name][:email]= pre_resource.email unless pre_resource.blank? 
    end    
    
    ## check email and send reset link
    self.resource = resource_class.send_reset_password_instructions(params[resource_name])
    
    if resource.errors.empty?
      #set_flash_message(:notice, :send_instructions) #if is_navigational_format?
      #tfarespond_with resource, :location => after_sending_reset_password_instructions_path_for(resource_name)
      msg = nil
      success = true
    else
      msg = resource.errors.full_messages.join(",")
      msg.gsub!("Email","Email or Nickname") if msg.include?("Email")
      success = false
      #respond_with_navigational(resource){ render_with_scope :new }
    end
    
    @raw_result = {
      :code => (success == true) ? 0 : 1,
      :error_message => msg,
      :value => {
        :send_reset_link => success
      }
    }
    render :json => JSON.generate(@raw_result)
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  def edit
    self.resource = resource_class.new
    resource.reset_password_token = params[:reset_password_token]
    render_with_scope :edit
  end

  # PUT /resource/password
  def update
     
    if params[resource_name][:password].blank? 
      success = false
      flash[:notice] = "password can't be blank"    
    elsif params[resource_name][:password_confirmation].blank? 
      success = false
      flash[:notice] = "password confirmation can't be blank"  
    elsif params[resource_name][:password_confirmation] != params[resource_name][:password]
      success = false
      flash[:notice] = "password and password confirmation don't match"
    else  
      self.resource = resource_class.reset_password_by_token(params[resource_name])
      
      if resource.errors.empty?
        set_flash_message(:notice, :updated) #if is_navigational_format?
        sign_in(resource_name, resource)
        success = true
      else
        flash[:notice] = "some errors has been occured : #{resource.errors.full_messages.join(',')}"
        success = false
      end
    end  
    
    if success == false
      redirect_to "/users/password/edit?reset_password_token=#{params[resource_name][:reset_password_token]}"
    else
      render :text => "password has been changed succesfully"    
    end    
  end
  
  protected

    # The path used after sending reset password instructions
    def after_sending_reset_password_instructions_path_for(resource_name)
      new_session_path(resource_name)
    end
    
end
