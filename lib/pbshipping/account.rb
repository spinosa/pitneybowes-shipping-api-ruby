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
# File: account.rb
# Description: account management functions
# 

module PBShipping
  class Account < ShippingApiResource
    
    #
    # MANAGING MERCHANTS
    # API: GET /ledger/accounts/{accountNumber}/balance
    # API signature: get/ledger/accounts/.../balance
    #
    # Retrieve the account balance of a merchant account.   
    #    
    def getBalance(auth_obj)
      if self.key?(:accountNumber) == false
        raise MissingResourceAttribute.new(:accountNumber)
      end
      api_sig = "get/ledger/accounts/.../balance"
      api_version = PBShipping::get_api_version(api_sig)
      api_path = "/ledger/accounts/" + self[:accountNumber] + "/balance"
      json_resp = PBShipping.api_request(auth_obj, :get, api_version, api_path, 
                                         {}, {}, {})
      return ApiObject.new(json_resp)
    end
    
    def self.getBalanceByAccountNumber(auth_obj, accountNumber)
      return Account.new({:accountNumber => accountNumber}).getBalance(auth_obj)
    end
  end
end