# -*- encoding : utf-8 -*-
class CyworldController < ApplicationController
  before_filter :authenticate_user!
  
  def connect
=begin    
    clnt = HTTPClient.new 
    
    uri = "https://oauth.nate.com/OAuth/GetRequestToken/V1a"
    body = { 
      'oauth_consumer_key' => 'a869b27692b1d1ca4bab30c9d33b102f04d679b66',  
      'oauth_timestamp' => Time.now.to_i,
      'oauth_signature_method' => "HMAC-SHA1",
      'oauth_signature' => sig,
      'oauth_nonce' => nonce,
      'oauth_version' => "1.0",
      'oauth_callback' => 'http://pumpl.com/cyworld/confirm'
    }



    res = clnt.post(uri, body)
    render :text => res.content

    client_options = {
      :site => 'https://oauth.nate.com',
      :authorize_path => "/OAuth/Authorize/V1a",
      :access_token_path => "/OAuth/GetAccessToken/V1a",
      :request_token_path => '/OAuth/GetRequestToken/V1a',
      :oauth_version => "1.0"
    }
=end
  @request_token = CYWORLD_CONSUMER.get_request_token
  @api_user.update_attribute(:cyworld_request_token_response, @request_token.params)
  
  respond_to do |format|
    format.json {
      @raw_result = {
        :code => 0,
        :error_message => nil,
        :value => {
          :authorize_url => @request_token.authorize_url
        }
      }
      render :json => JSON.generate(@raw_result)
    }
    format.html {
      redirect_to authorize_path
    }
  end

=begin
OAuth::Consumer.new(consumer_key, consumer_secret,
                               :site => "http://api.justin.tv",
                               :request_token_path => "/oauth/request_token",
                               :authorize_path => "/oauth/authorize",
                               :access_token_path => "/oauth/access_token",
                               :http_method => :get)
                         


    @consumer=OAuth::Consumer.new("a869b27692b1d1ca4bab30c9d33b102f04d679b66",nil,{
      :site=>"https://oauth.nate.com",
      :request_token_path => "/OAuth/GetRequestToken/V1a",
      :authorize_path => "/OAuth/Authorize/V1a",
      :access_token_path => "/OAuth/GetAccessToken/V1a",
      :http_method => :post
    })    
    debugger
    #access_token = OAuth::AccessToken.new @consumer
    request_token = @consumer.get_request_token
    session[:request_token] = request_token
    
    render :text => request_token.authorize_url
=end     
    

    

  end
  
  def confirm
    @request_token = @api_user.cyworld_request_token
    @access_token = CYWORLD_CONSUMER.get_access_token @request_token, {:oauth_verifier => params[:verifier]}
    @api_user.update_attribute(:cyworld_access_token_response, @access_token.params)

    respond_to do |format|
      format.json {
        render :json => Hash.from_xml(response.body).to_json
      }
      format.html {
        redirect_to authorize_path
      }
    end
  end

  protected

  def sig
  key = 'a869b27692b1d1ca4bab30c9d33b102f04d679b66'
  signature = 'abcdef'
  return Base64.encode64("#{OpenSSL::HMAC.digest('sha1',key, signature)}\n")
  end
  
  def nonce
    rand(10 ** 30).to_s.rjust(30,'0')
  end
end
