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
    self.resource = resource_class.send_reset_password_instructions(params[resource_name])
    
    if resource.errors.empty?
      set_flash_message(:notice, :send_instructions) #if is_navigational_format?
      #tfarespond_with resource, :location => after_sending_reset_password_instructions_path_for(resource_name)
      success = true
    else
      success = false
      #respond_with_navigational(resource){ render_with_scope :new }
    end
    
    @raw_result = {
      :code => (success == true) ? 1 : 0,
      :error_message => resource.errors.full_messages.join(","),
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
    self.resource = resource_class.reset_password_by_token(params[resource_name])

    if resource.errors.empty?
      set_flash_message(:notice, :updated) if is_navigational_format?
      sign_in(resource_name, resource)
      respond_with resource, :location => redirect_location(resource_name, resource)
    else
      respond_with_navigational(resource){ render_with_scope :edit }
    end
  end
  
  protected

    # The path used after sending reset password instructions
    def after_sending_reset_password_instructions_path_for(resource_name)
      new_session_path(resource_name)
    end
    
end
