
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