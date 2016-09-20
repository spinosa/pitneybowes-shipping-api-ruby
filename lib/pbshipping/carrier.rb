module PBShipping
  class Carrier < ShippingApiResource
 
    #
    # COUNTRIES LIST
    # API: GET /countries
    # API signature: get/countries
    #
    # Returns a list of supported destination countries to which the carrier 
    # offers international shipping services. 
    #
    def getCountries(auth_obj, originCountryCode)
      if self.key?(:name) == false
        raise MissingResourceAttribute.new(:name)
      end
      params = {
        "carrier" => self[:name], 
        "originCountryCode" => originCountryCode
        }
      api_sig = "get/countries"
      api_version = PBShipping::get_api_version(api_sig)
      api_path = "/countries"
      json_resp = PBShipping.api_request(auth_obj, :get, api_version, api_path, 
                                         {}, params, {})
      country_list = []
      json_resp.each { |country| country_list << Country.new(country) }
      return country_list
    end
    
    def self.getCountriesForCarrier(auth_obj, carrier_name, originCountryCode)
      return Carrier.new({:name => carrier_name}).getCountries(
        auth_obj, originCountryCode)
    end
  end
end