
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