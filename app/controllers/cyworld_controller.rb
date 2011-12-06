# -*- encoding : utf-8 -*-
class CyworldController < ApplicationController
  before_filter :authenticate_user!
  
  def connect

    @request_token = cyworld_consumer.get_request_token
    #@api_user.update_attribute(:cyworld_request_token_response, @request_token.params)
    #@api_user.update_attributes(
    #  :cyworld_key => @request_token.params[:oauth_token],
    #  :cyworld_secret => @request_token.params[:oauth_token_secret] 
    #)
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

  end
  
  def confirm
    @request_token = cyworld_consumer.get_request_token
    @access_token = cyworld_consumer.get_access_token @request_token, {:oauth_verifier => params[:verifier]}
    
    @api_user.update_attributes!(
      :cyworld_key => @access_token.token,
      :cyworld_secret => @access_token.secret 
    )
    
    Rails.logger.info "CYWORLD KEY #{@api_user.cyworld_key}"
    Rails.logger.info "CYWORLD SECRET #{@api_user.cyworld_secret}"
    
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
  
  def cyworld_consumer
    OAuth::Consumer.new(CYWORLD_KEY, CYWORLD_SECRET, CYWOLRD_CLIENT_OPTIONS)
  end  

  def sig
  key = 'a869b27692b1d1ca4bab30c9d33b102f04d679b66'
  signature = 'abcdef'
  return Base64.encode64("#{OpenSSL::HMAC.digest('sha1',key, signature)}\n")
  end
  
  def nonce
    rand(10 ** 30).to_s.rjust(30,'0')
  end
end
