#
# Copyright 2016 Pitney Bowes Inc.
#
# Licensed under the MIT License (the "License"); you may not use this file 
# except in compliance with the License. You may obtain a copy of the License 
# in the LICENSE file or at 
#     https://opensource.org/licenses/MIT
#
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT 
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  
# See the License for the specific language governing permissions and 
# limitations under the License.
#
# File: carrier.rb
# Description: carrier query such as supported countries
# 

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