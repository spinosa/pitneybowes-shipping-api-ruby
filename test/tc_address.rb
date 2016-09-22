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
# File: tc_address.rb
# Description: unit test for address verification
# 

require "test/unit"
require "pbshipping"
require_relative "test_util"

class TestAddress < Test::Unit::TestCase

  def setup
    @auth_obj = PBShipping::AuthenticationToken.new(
      PBShippingTestUtil::api_key, PBShippingTestUtil::api_secret) 
  end

  def teardown
  end

  def test_address
    puts "Testing get countries call ..."
    usps_carrier = PBShipping::Carrier.new({:name => "usps"})
    usps_carrier.getCountries(@auth_obj, "US")  
    
    puts "Testing address verification ..." 
    # expect the address is cleansed and changed
    address = PBShipping::Address.new(PBShippingTestUtil::my_origin_addr);
    address.verify(@auth_obj, false)
    assert_equal(address[:status].downcase, "validated_changed")
  
  end

end