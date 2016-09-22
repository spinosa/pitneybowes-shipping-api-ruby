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
# File: test_util.rb
# Description: helper classes and functions supporting unit test
# 

require 'bigdecimal'

module PBShippingTestUtil
 
 @api_key = ENV["PBSHIPPING_KEY"]
 @api_secret = ENV["PBSHIPPING_SECRET"]
 @dev_id = ENV["PBSHIPPING_DEVID"]
 @merchant_email = ENV["PBSHIPPING_MERCHANT"]
 
 @my_bulk_merchant_addr = { 
    :addressLines => ["27 Waterview Drive"], 
    :cityTown => "Shelton", 
    :stateProvince => "Connecticut", 
    :postalCode => "06484", 
    :countryCode => "US", 
    :company => "Pitney Bowes", 
    :name => "John Doe", 
    :email => "dummy@pbshipping.com", 
    :phone => "203-792-1600", 
    :residential => false 
  }
  
  @my_origin_addr = {
    :addressLines => ["37 Executive Drive"],
    :cityTown => "Danbury",
    :stateProvince => "Connecticut",
    :postalCode => "06810",
    :countryCode => "US"
  }
  
  @my_dest_addr = {
    :addressLines => ["27 Waterview Drive"], 
    :cityTown => "Shelton",
    :stateProvince => "Connecticut",
    :postalCode => "06484",
    :countryCode => "US"
  }
  
  @my_parcel = {
    :weight => {
        :unitOfMeasurement => "OZ",
        :weight => 1
    },
    :dimension => {
        :unitOfMeasurement => "IN",
        :length => 6,
        :width => 0.25,
        :height => 4,
        :irregularParcelGirth => 0.002
    }
  }
  
  @my_rate_request_carrier_usps = {
    :carrier => "usps",
    :serviceId => "PM",
    :parcelType => "PKG",
    :specialServices => [
        {
            :specialServiceId => "Ins",
            :inputParameters => [
                {
                    :name => "INPUT_VALUE",
                    :value => "50"
                }
             ]
        },
        {
            :specialServiceId => "DelCon",
            :inputParameters => [
                {
                    :name => "INPUT_VALUE",
                    :value => "0"
                }
             ]
        }
    ],
    :inductionPostalCode => "06810"
  }
  
  @my_shipment_document = {
    :type => "SHIPPING_LABEL",
    :contentType => "URL",
    :size => "DOC_8X11",
    :fileFormat => "PDF",
    :printDialogOption => "NO_PRINT_DIALOG"
  }

  # this helps to identify transactions originating from the test suite
  @test_suite_txid_prefix = "KYCB"
  
  class << self
    attr_accessor :api_key, :api_secret, :dev_id, :merchant_email
    attr_accessor :my_bulk_merchant_addr, :my_origin_addr, :my_dest_addr
    attr_accessor :my_parcel, :my_rate_request_carrier_usps, :my_shipment_document
    attr_accessor :test_suite_txid_prefix
  end
   
  def self.get_pb_tx_id()
    return @test_suite_txid_prefix + Time.now.utc.strftime("%Y%m%d%H%M%S%6N")
  end

  def self.setup_developer(auth_obj)
    developer = PBShipping::Developer.new(
      { :developerId => PBShippingTestUtil::dev_id} )
    developer.refresh(auth_obj)  
    return developer  
  end
  
  def self.setup_merchant(auth_obj, developer)
    if developer.bulkMode == false
      merchant = developer.registerMerchantIndividualAccount(
        auth_obj, @merchant_email)
      acct_num = merchant.paymentAccountNumber        
    else
      begin
        @my_bulk_merchant_addr[:email] = @merchant_email
        merchant = developer.registerMerchantBulkAccount(
          auth_obj, @my_bulk_merchant_addr)      
      rescue => e
        case e
        when PBShipping::ApiError
          if e.error_info.length < 1 
            raise e
          elsif !(e.error_info[0][:message].include?("Duplicate entry"))
            raise e
          end  
          merchant = developer.getMerchantBulkAccount(auth_obj, @merchant_email)
        else
          raise e
        end     
      end
      acct_num = developer.paymentAccount
    end
    return merchant, acct_num
  end

  def self.check_shipment_rate(auth_obj, developer)
    rates = [ PBShipping::Rate.new(@my_rate_request_carrier_usps) ]
    parcel = PBShipping::Parcel.new(@my_parcel)     
    shipment = PBShipping::Shipment.new({
      :fromAddress => PBShippingTestUtil::my_origin_addr, 
      :toAddress => PBShippingTestUtil::my_dest_addr,
      :parcel => parcel, 
      :rates => rates
    })
    txid = PBShippingTestUtil::get_pb_tx_id()
    xtra_hdrs = nil
    if developer.bulkMode == true and developer.useShipperRate == true
        xtra_hdrs = {"X-PB-Shipper-Rate-Plan" => "PP_SRP_NEWBLUE"}  
    end  
    rates = shipment.getRates(auth_obj, txid, true, xtra_hdrs) 
    return rates[0].totalCarrierCharge   
  end
  
  def self.create_single_shipment(auth_obj, developer, shipper_id)
    rates = [ PBShipping::Rate.new(@my_rate_request_carrier_usps) ]
    parcel = PBShipping::Parcel.new(@my_parcel)     
    documents = [ PBShipping::Document.new(@my_shipment_document)]
    shipmentOptions = [
      PBShipping::ShipmentOptions.new(
        { :name => "SHIPPER_ID", :value => shipper_id }),
      PBShipping::ShipmentOptions.new(
        { :name => "ADD_TO_MANIFEST", :value => true })
    ]      
    shipment = PBShipping::Shipment.new({
      :fromAddress => PBShippingTestUtil::my_origin_addr, 
      :toAddress => PBShippingTestUtil::my_dest_addr,
      :parcel => parcel, 
      :rates => rates,
      :documents => documents,
      :shipmentOptions => shipmentOptions
    })    
    txid = PBShippingTestUtil::get_pb_tx_id()
    xtra_hdrs = nil
    if developer.bulkMode == true and developer.useShipperRate == true
        xtra_hdrs = {"X-PB-Shipper-Rate-Plan" => "PP_SRP_NEWBLUE"}  
    end    
    shipment.createAndPurchase(auth_obj, txid, true, xtra_hdrs)       
    return shipment, txid
  end
  
  # verify the ledger balance is correct after shipment label purchase
  def self.verify_ledger_balance_after_txn(shipment, start_balance, end_balance)
    
    balance_delta = BigDecimal(start_balance.balance - end_balance.balance, 3)
    # if account has been replenished using auto-refill, skip this case
    if balance_delta < 0
      puts "    ending balance increases, probably due to auto reload, skip check"
      return true
    end
    
    txn_charge = BigDecimal(shipment.rates[0].totalCarrierCharge, 3)
    
    is_same = (txn_charge == balance_delta)
    if is_same == false
      delta = txn_charge - balance_delta
      msg = "    verify balance failed: difference is " + delta.to_s
      puts msg
    end
    
    return is_same
  end

end
