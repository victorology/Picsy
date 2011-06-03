# -*- encoding : utf-8 -*-
class Admin::ReferralsController < ApplicationController
  before_filter :authenticate_user!
  layout "admin"
  
  def index
    @invites = Invite.all
  end  
end
