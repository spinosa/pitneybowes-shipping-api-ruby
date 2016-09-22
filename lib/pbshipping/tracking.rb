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
# File: tracking.rb
# Description: shipment tracking functions
# 

module PBShipping
  class Tracking < ShippingApiResource
    
    #
    # TRACKING
    # API: GET /tracking/{trackingNumber}
    # API signature: get/tracking/...
    #
    # Shipment labels that are printed using the Pitney Bowes APIs are 
    # automatically tracked and their package status can be easily retrieved 
    # using this implementation of the GET operation.
    #    
    def updateStatus(auth_obj) 
      if self.key?(:trackingNumber) == false
        raise MissingResourceAttribute.new(:trackingNumber)
      end
      if self.key?(:packageIdentifierType) == false
        self[:packageIdentifierType] = "TrackingNumber"
      end
      if self.key?(:carrier) == false
        self[:carrier] = "USPS"
      end
      params = {
        :carrier => self[:carrier],
        :packageIdentifierType => self[:packageIdentifierType]
      }
      api_sig = "get/tracking/..."
      api_version = PBShipping::get_api_version(api_sig)
      api_path = "/tracking/" + self[:trackingNumber]
      json_resp = PBShipping::api_request(
        auth_obj, :get, api_version, api_path, {}, params, {})
      self.update(json_resp)
    end
  end
end