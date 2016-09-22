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
# File: tc_manifest.rb
# Description: unit test for manifest manipulation
# 

require "test/unit"
require "pbshipping"

class TestManifest < Test::Unit::TestCase

  def setup
    @auth_obj = PBShipping::AuthenticationToken.new(
      PBShippingTestUtil::api_key, PBShippingTestUtil::api_secret)
    @developer = PBShippingTestUtil::setup_developer(@auth_obj)    
    merchant, @acct_num = PBShippingTestUtil::setup_merchant(
      @auth_obj, @developer) 
    @shipper_id = merchant.postalReportingNumber
                           
  end

  def teardown 
  end

  def test_manifest
    
    shipment1, txid1 = PBShippingTestUtil::create_single_shipment(
      @auth_obj, @developer, @shipper_id)
    shipment2, txid2 = PBShippingTestUtil::create_single_shipment(
      @auth_obj, @developer, @shipper_id)      
      
    carrier = PBShippingTestUtil::my_rate_request_carrier_usps[:carrier]
    trk_nums = [shipment1.parcelTrackingNumber, 
                shipment2.parcelTrackingNumber]
                
    manifest = PBShipping::Manifest.new( {
      :carrier => carrier, 
      :submissionDate => Time.now.utc.strftime("%Y-%m-%d"),
      :parcelTrackingNumbers => trk_nums,
      :fromAddress => shipment1.fromAddress
    } )                

    puts "Testing manifest creation ..."       
    original_txid = PBShippingTestUtil::get_pb_tx_id()
    manifest.create(@auth_obj, original_txid)
    assert_equal(manifest.key?(:manifestId), true)
                        
    puts "Testing reprint manifest ..."
    manifest.reprint(@auth_obj)
        
    puts "Testing retry manifest ..."
    txid = PBShippingTestUtil::get_pb_tx_id()
    manifest.retry(@auth_obj, txid, original_txid)
    
  end

end