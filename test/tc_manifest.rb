
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