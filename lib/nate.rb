require 'omniauth/oauth'
require 'multi_json'
require 'base64'
require 'openssl'

module OmniAuth
  module Strategies
    #
    # Authenticate to Twitter via OAuth and retrieve basic
    # user information.
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::Nate, 'consumerkey', 'consumersecret'
    #
    class Nate < OmniAuth::Strategies::OAuth
      # Initialize the middleware
      #
      # @option options [Boolean, true] :sign_in When true, use the "Sign in with Nate" flow instead of the authorization flow.
      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        client_options = {
          :site => 'https://oauth.nate.com',
          :authorize_path => "/OAuth/Authorize/V1a",
          :access_token_path => "/OAuth/GetAccessToken/V1a",
          :request_token_path => '/OAuth/GetRequestToken/V1a',
          :oauth_version => "1.0"
        }
        super(app, :nate, consumer_key, consumer_secret, client_options, options)
      end
            
      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid'       => @access_token.params[:user_id],
          'user_info' => user_info,
          'extra'     => { 'user_hash' => user_hash }
        })        
      end

      def user_info
        #암호화 방식	 : TRIPLE DES(블럭 : CBC, 패딩 : PKCS5Padding)
        #Key 값	 : hL3IPKlXrsXlLYnRwkGilKyl2QRKL41R
        #IV 값	 : \0 값의 8 byte padding
        user_hash = self.user_hash
        {
          'name' => user_hash['name'],
          'nid' => user_hash['nid']
        }
      end

      def user_hash
        @user_hash ||= Hash.from_xml(@access_token.get('/OAuth/GetNateMemberInfo/V1a').body)
      end
    end
  end
end