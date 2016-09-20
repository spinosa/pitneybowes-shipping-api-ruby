require 'rest-client'
require 'json'
require 'base64'
require 'bigdecimal'

require_relative 'pbshipping/error.rb'
require_relative 'pbshipping/api_object.rb'
require_relative 'pbshipping/api_resource.rb'
require_relative 'pbshipping/shipping_api_resource.rb'
require_relative 'pbshipping/account.rb'
require_relative 'pbshipping/address.rb'
require_relative 'pbshipping/authentication.rb'
require_relative 'pbshipping/carrier.rb'
require_relative 'pbshipping/country.rb'
require_relative 'pbshipping/customs.rb'
require_relative 'pbshipping/developer.rb'
require_relative 'pbshipping/manifest.rb'
require_relative 'pbshipping/merchant.rb'
require_relative 'pbshipping/parcel.rb'
require_relative 'pbshipping/rate.rb'
require_relative 'pbshipping/scandetails.rb'
require_relative 'pbshipping/shipment.rb'
require_relative 'pbshipping/tracking.rb'
require_relative 'pbshipping/transactiondetails.rb'

module PBShipping

  @configuration = {
    :sandbox => "https://api-sandbox.pitneybowes.com",
    :production => "https://api.pitneybowes.com",
    :is_production => false,
    :default_api_version => "/v1",
    :override_api_version => {
      "post/developers/.../merchants/registration" => "/v2",
      "get/ledger/developers/.../transactions/reports" => "/v2"
    }
  }
  @api_group_shipping = "/shippingservices"
  @txid_attrname = "X-PB-TransactionId"    

  class << self
    attr_accessor :configuration, :api_group_shipping, :txid_attrname
  end

  def self.get_api_version(api_sig)
    if @configuration[:override_api_version].key?(api_sig) == true
      api_version = @configuration[:override_api_version][api_sig]
    else 
      api_version = @configuration[:default_api_version]
    end
    return api_version  
  end
  
  def self.api_url(api_version, api_path)
    if @configuration[:is_production] == true
      api_server = @configuration[:production]
    else
      api_server = @configuration[:sandbox] 
    end
    api_server + @api_group_shipping + api_version + api_path
  end

  def self.authenticate_request(api_key, api_secret)
    if @configuration[:is_production] == true
      api_server = @configuration[:production]
    else
      api_server = @configuration[:sandbox] 
    end
    url = api_server + "/oauth/token"
   
    headers = {
      :content_type => 'application/x-www-form-urlencoded',
      :Authorization => 'Basic ' + Base64.strict_encode64(api_key + ":" + api_secret)
    }
    payload = {
      :grant_type => 'client_credentials'
    }
    opts = {
      :method => 'post',
      :payload => payload,
      :headers => headers,
      :url => url,
      :open_timeout => 15,
      :timeout => 30
    }
    
    begin
      res = make_http_request(opts)
      json_parse(res)
    rescue => e
      case e
      when RestClient::Exception
        raise AuthenticationError.new(e.to_s, e.http_code, e.http_body) 
      else
        raise AuthenticationError.new(e.to_s)
      end           
    end  
  end
  
  def self.api_request(auth_obj, method, api_version, api_path, headers = {}, params = {}, payload = {})
    if auth_obj == nil || auth_obj.access_token == nil
      raise AuthenticationError.new("Invalid or missing authentication credentials")
    end
    begin
      url = api_url(api_version, api_path)
      headers.merge!(
        :accept => :json,
        :content_type => :json,
        :Authorization => "Bearer " + auth_obj.access_token
      )
      case method
      when :get    
        payload = {}        
        pairs = []
        params.each { |k, v|
          pairs.push "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}"
        }
        url += "?#{pairs.join('&')}" unless pairs.empty?
      end
      opts = { 
        :headers => headers,
        :method => method,
        :payload => payload.to_json,
        :url => url,
        :open_timeout => 15,
        :timeout => 30,
        :user_agent => "pbshipping/v1 RubyBindings"
      }
      res = make_http_request(opts)
      json_parse(res)      
    rescue => e
      case e
      when RestClient::Exception
        raise ApiError.new(e.to_s, e.http_code, e.http_body) 
      else
        raise ApiError.new(e.to_s)
      end 
    end
  end
  
  def self.json_parse(response)
    JSON::parse(response.body, { :symbolize_names => true })
  end
end

def make_http_request(opts)
  RestClient::Request.execute(opts){ |response, request, result, &block|
    if [301, 302, 307].include? response.code
      response.follow_redirection(request, result, &block)
    else
      response.return!(request, result, &block)
    end
  }
end
