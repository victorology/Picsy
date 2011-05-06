# -*- encoding : utf-8 -*-
class Me2dayController < ApplicationController
  def index
    #clnt = HTTPClient.new
    #extheader = { 'APP-KEY' => ME2DAY_KEY }
    #rs = clnt.get("http://me2day.net/api/get_auth_url.xml",extheader)
    c = Curl::Easy.new("http://me2day.net/api/get_auth_url.xml") do |curl| 
      curl.headers["me2_application_key"] = ME2DAY_KEY
      curl.verbose = true
    end
    #c = Curl::Easy.http_post("http://me2day.net/api/get_auth_url.json",
    #                         Curl::PostField.content("APP-KEY", ME2DAY_KEY))
    
    c.perform
    render :text => c.body_str
  end  
end
