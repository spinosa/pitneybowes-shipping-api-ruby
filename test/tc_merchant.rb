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
# File: tc_merchant.rb
# Description: unit test for merchant account query and registration
# 

require "test/unit"
require "pbshipping"
require_relative "test_util"

class TestMerchant < Test::Unit::TestCase

  def setup
    @auth_obj = PBShipping::AuthenticationToken.new(
      PBShippingTestUtil::api_key, PBShippingTestUtil::api_secret) 
    puts ""      
  end

  def teardown
  end

  def test_Merchant
    developer = PBShippingTestUtil::setup_developer(@auth_obj)
 
    puts "Testing merchant registration ..."
    merchant, acct_num = PBShippingTestUtil::setup_merchant(@auth_obj, developer)

    puts "Testing account balance query ..."    
    balance = PBShipping::Account.getBalanceByAccountNumber(@auth_obj, acct_num)  
  end

end