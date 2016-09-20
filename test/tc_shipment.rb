
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