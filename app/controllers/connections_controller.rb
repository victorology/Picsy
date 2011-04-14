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
