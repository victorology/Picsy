# -*- encoding : utf-8 -*-
class Me2dayController < ApplicationController
  def index
    auth_url = Me2day::Client.get_auth_url(:app_key => ME2DAY_KEY)
    redirect_to auth_url        
  end  
  
  def confirm
    #token, user_id, user_key, result = request.params["token"], request.params["user_id"], request.params["user_key"], request.params["result"]

    #if params[:result] == 'true'

        @client = Me2day::Client.new(
            :user_id => params[:user_id],
            :user_key => params[:user_key],
            :app_key => ME2DAY_KEY
        )

       # @client.noop
      #  => {"error"=>{"code"=>"0", "description"=>nil, "message"=>"\354\204\261\352\263\265\355\226\210\354\212\265\353\213\210\353\213\244."}}

       # @client.create_post 'me2_id', 'post[body]' => "오늘의 미친 짓!"
       debugger
       a.a
    #end
    
  end  
end
