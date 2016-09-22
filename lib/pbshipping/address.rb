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
# File: address.rb
# Description: address verification functions
# 

module PBShipping
  class Address < ShippingApiResource    

    #
    # ADDRESS VALIDATION
    # API: POST /addresses/verify
    # API signature: post/addresses/verify
    #
    # Verify and cleanse any postal address within the United States. 
    # This will ensure that packages are rated accurately and the 
    # shipments arrive at their final destination on time.
    #
    # By default, the returned result would overwrite the current state 
    # of the object. To avoid overwriting, set the input argument 
    # overwrite to False and a copy of the result would be generated and
    # returned instead      
    #
    def verify(auth_obj, minimalAddressValidation=nil, overwrite=true)
      if minimalAddressValidation == nil
        hdrs = {"minimalAddressValidation" => false}
      else
        hdrs = {"minimalAddressValidation" => minimalAddressValidation}
      end
      api_sig = "post/address/verify"
      api_version = PBShipping::get_api_version(api_sig)
      api_path = "/addresses/verify"
      json_resp = PBShipping::api_request(
        auth_obj, :post, api_version, api_path, hdrs, {}, self)
      if overwrite == true 
        self.update(json_resp)
        self
      else  
        Address.new(json_resp)
      end  
    end
  end
end
