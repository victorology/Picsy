# -*- encoding : utf-8 -*-
class CustomFailure < Devise::FailureApp
  def redirect_url
    sign_in_admin_users_url(:msg => "login failed")
  end

  # You need to override respond to eliminate recall
  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end
