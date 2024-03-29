# -*- encoding : utf-8 -*-
class ConnectionsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    respond_to do |format|
      format.json {
        @raw_result = {
          :code => 0,
          :error_message => nil,
          :value => {
            :facebook => {
              :is_connected => current_user.facebook_connected?,
              :nickname => current_user.facebook_nickname
            },
            :twitter => {
              :is_connected => current_user.twitter_connected?,
              :nickname => current_user.twitter_nickname
            },
            :tumblr => {
              :is_connected => current_user.tumblr_connected?,
              :nickname => current_user.tumblr_nickname
            },
            :me2day => {
               :is_connected => current_user.me2day_connected?,
               :id => current_user.me2day_id
             }
          }
        }
        render :json => JSON.generate(@raw_result)
      }
      format.html {
      }
    end
  end      
end
