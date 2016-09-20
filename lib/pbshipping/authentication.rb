module PBShipping
  class AuthenticationToken
    attr_accessor :api_key, :api_secret, :access_token, :auth_info
    
    def initialize(api_key, api_secret)
      @api_key = api_key
      @api_secret = api_secret
      @access_token = nil
      @auth_info = nil
      refresh_token()
    end
    
    def refresh_token()
      @auth_info = PBShipping::authenticate_request(@api_key, @api_secret)
      @access_token = @auth_info[:access_token]
    end
  end
end