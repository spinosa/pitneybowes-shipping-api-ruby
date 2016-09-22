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
# File: tc_shipment.rb
# Description: unit test for shipment creation and management
# 

require "test/unit"
require "pbshipping"

class TestShipment < Test::Unit::TestCase

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

  def test_shipment
 
    puts "Testing rate query and purchasing shipment label ..."
    
    start_balance = PBShipping::Account.getBalanceByAccountNumber(
      @auth_obj, @acct_num)  
    PBShippingTestUtil::check_shipment_rate(@auth_obj, @developer)
    shipment, orig_txid = PBShippingTestUtil::create_single_shipment(
      @auth_obj, @developer, @shipper_id)  
    end_balance = PBShipping::Account.getBalanceByAccountNumber(
      @auth_obj, @acct_num)     
      
    assert_equal(shipment.key?(:shipmentId), true)
    assert_equal(PBShippingTestUtil::verify_ledger_balance_after_txn(
      shipment, start_balance, end_balance), true)

    puts "Testing get tracking status ..."
    tracking = PBShipping::Tracking.new( 
      { :trackingNumber => shipment.parcelTrackingNumber } )
    begin
        tracking.updateStatus(@auth_obj)        
    rescue => e
      case e
      when PBShipping::ApiError 
        if PBShipping::configuration[:is_production] == true
          raise e
        elsif e.error_info.length < 1 
          raise e
        elsif e.error_info[0][:errorCode] != "PB-TRKPKG-ERR-7600"
          raise e
        else
          puts "   no tracking information in sandbox environment"          
        end
      else
        raise e
      end 
    end
    
    puts "Testing reprint shipment label ..."
    shipment.reprintLabel(@auth_obj)
    
    puts "Testing retry shipment ..."
    txid = PBShippingTestUtil::get_pb_tx_id()
    shipment.retry(@auth_obj, txid, orig_txid) 
                                                                             
    puts "Testing canceling shipment ..."     
    cancel_result = shipment.cancel(@auth_obj, orig_txid, 
      shipment.rates[0].carrier)
    assert_equal(cancel_result.key?(:status), true)
    
  end

end