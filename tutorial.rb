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
# File: tutorial.rb
# Description: a tutorial example exercising the shipping apis
# 

# Tutorial
require 'optparse'
require "json"
require 'pbshipping'

module PBShippingTutorial

  @api_key = nil
  @api_secret = nil
  @dev_id = nil
  @merchant_email = nil
  @merchant = nil
  @from_addr = nil
  @to_addr = nil
  @shipment = nil
  @shipment_orig_tx_id = nil
  @tracking = nil
  @manifest = nil
  @manifest_orig_tx_id = nil
  @auth_obj = nil

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

  # use the current timestamp to generate a transaction id
  def self.get_pb_tx_id()
    
    Time.now().to_i.to_s
  end

  # obtain authentication, developer, and merchant infomration from 
  # command line  
  def self.initialize_info() 

    options = {}
    
    # try environment variables ...    
    if ENV["PBSHIPPING_KEY"] != nil 
      options[:key] = ENV["PBSHIPPING_KEY"]
    end
    if ENV["PBSHIPPING_SECRET"] != nil 
      options[:secret] = ENV["PBSHIPPING_SECRET"]
    end
    if ENV["PBSHIPPING_DEVID"] != nil 
      options[:devid] = ENV["PBSHIPPING_DEVID"]
    end
    if ENV["PBSHIPPING_MERCHANT"] != nil 
      options[:merchant] = ENV["PBSHIPPING_MERCHANT"]
    end
            
    optparse = OptionParser.new do |opts|
      opts.banner = "Usage: tutorial.rb [options]"
      # command line arguments overwrite environment variables
      opts.on('-h', '--help', 'Display help') do
        puts opts
        exit
      end
      opts.on('-k', '--key API_KEY', 'API key for authentication') do |api_key|
        options[:key] = api_key
      end
      opts.on('-s', '--secret API_SECRET', 'API secret for authentication') do |api_secret|
        options[:secret] = api_secret
      end        
      opts.on('-d', '--devid DEVELOPER_ID', 'Pitney Bowes Developer ID') do |dev_id|
        options[:devid] = dev_id
      end          
      opts.on('-m', '--merchant MERCHANT_EMAIL', 'Merchant email') do |merchant_email|
        options[:merchant] = merchant_email
      end    
    end  
    
    begin
      optparse.parse!
      mandatory = [:key, :secret, :devid, :merchant]
      missing = mandatory.select{ |param| options[param].nil? }
      unless missing.empty?
        puts "Missing options: #{missing.join(', ')}"
        puts optparse
        exit
      end
      @api_key = options[:key]
      @api_secret = options[:secret]
      @dev_id = options[:devid]
      @merchant_email = options[:merchant]
    rescue OptionParser::InvalidOption, OptionParser::MissingArgument
      puts $!.to_s
      puts optparse
      exit
    end
  end

  # choose sandbox or production pitney bowes shipping api server
  def self.choose_environment()
    
    puts "Choose the sandbox environment ..."
    PBShipping::configuration[:is_production] = false
  end
      
  # authenticate and obtain the authentication object for subsequent use
  # underlying API: POST /oauth/token  
  def self.authenticate()
    
    puts 'Authenticating ...'
    @auth_obj = PBShipping::AuthenticationToken.new(@api_key, @api_secret)    
  end

  # return the list of supported countries 
  # underlying API: GET /countries
  def self.check_carrier_supported_countries()
    
    puts "Querying for supported countries of USPS carrier ..."
    country_list = PBShipping::Carrier.getCountriesForCarrier(@auth_obj, "usps", "US")
    n = country_list.length()
    puts "   number of supported countries is " + n.to_s
    puts "   one example is " + country_list[n/3].countryName
  end
 
  # managing merchant account under individual account mode
  # underlying API: GET /developers/{developerId}/merchants/emails/{emailId}/
  #                 GET /ledger/accounts/{accountNumber}/balance   
  def self.manage_individual_mode_merchant()
    
    # querying for merchant information
    puts "Managing merchant (individual account mode) ..."
    @developer = PBShipping::Developer.new( { :developerId => @dev_id } )
    @merchant = @developer.registerMerchantIndividualAccount(
      @auth_obj, @merchant_email)
    merchant_account_number = @merchant.paymentAccountNumber
    
    # querying for merchant account balance
    balance = PBShipping::Account.getBalanceByAccountNumber(
      @auth_obj, merchant_account_number)
    puts "   merchant full name is " + @merchant.fullName
    puts "   shipper id is " + @merchant.postalReportingNumber
    puts "   payment account number is " + merchant_account_number
    puts "   current balance is " + balance.currencyCode + " " + \
                                    balance.balance.to_s   
  end

  # managing merchant account under bulk account mode
  # underlying API: POST /developers/{developerId}/merchants/registration  
  def self.manage_bulk_mode_merchant()
    
    puts "Managing merchant (bulk account mode) ..."
    @developer = PBShipping::Developer.new( { :developerId => @dev_id } )
    merchant_addr = PBShipping::Address.new(@my_bulk_merchant_addr)
    merchant = @developer.registerMerchantBulkAccount(@auth_obj, merchant_addr)
    puts merchant
  end

  # verifying addresses
  # underlying API: POST /addresses/verify  
  def self.verify_addresses()
    
    puts "Verifying origin and destination addresses ... "
    @from_addr = PBShipping::Address.new(@my_origin_addr)
    @from_addr.verify(@auth_obj, false)
    if @from_addr.status.downcase == "validated_changed"
      puts "   origin address cleansed, addressLine is " + \
           @from_addr.addressLines[0]
    end
    
    @to_addr = PBShipping::Address.new(@my_dest_addr)
    @to_addr.verify(@auth_obj, false)
    if @to_addr.status.downcase == "validated_changed"
      puts "   destination address cleansed, addressLine is " + \
           @to_addr.addressLines[0]
    end
  end

  # querying rates to prepare a shipment
  # underlying API: POST /rates
  def self.prepare_shipment()

    puts "Preparing shipment and checking for shipment rates ..."
    rates = [ PBShipping::Rate.new(@my_rate_request_carrier_usps) ]
    parcel = PBShipping::Parcel.new(@my_parcel)     
    documents = [ PBShipping::Document.new(@my_shipment_document)]
    shipmentOptions = [
      PBShipping::ShipmentOptions.new({
        :name => "SHIPPER_ID", 
        :value => @merchant.postalReportingNumber
      }),
      PBShipping::ShipmentOptions.new({
        :name => "ADD_TO_MANIFEST", 
        :value => true 
      })
    ]              
    @shipment = PBShipping::Shipment.new({
      :fromAddress => @from_addr, 
      :toAddress => @to_addr,
      :parcel => parcel, 
      :rates => rates,
      :documents => documents,
      :shipmentOptions => shipmentOptions
    })
    @shipment.rates = @shipment.getRates(@auth_obj, get_pb_tx_id(), true)  
    puts "   total carrier charge: " + @shipment.rates[0][:totalCarrierCharge].to_s
  end

  # submit a shipment creation request and purchase a shipment label
  # underlying API: POST /shipments
  def self.create_and_purchase_shipment()

    puts "Creating shipment and purchasing label ..."
    @shipment_orig_tx_id = get_pb_tx_id()
    @shipment.createAndPurchase(@auth_obj, @shipment_orig_tx_id, true)
  
    puts "   parcel tracking number is " + @shipment.parcelTrackingNumber
    for doc in @shipment.documents
      puts "   document type is " + doc[:type]
      if doc[:contentType] == "URL" && doc.key?(:contents)
        puts "   document URL is " + doc[:contents]
      end
    end  
  end

  # reprint a shipment label
  # underlying API: GET /shipments/{shipmentId}
  def self.reprint_shipment()
    
    puts "Reprinting label ..."
    @shipment.reprintLabel(@auth_obj)
    for doc in @shipment.documents
      if doc[:contentType] == "URL" && doc.key?(:contents)
        puts "   document URL is " + doc[:contents]
      end
    end   
  end     

  # retry a shipment purchase request 
  # underlying API: GET /shipments?originalTransactionId    
  def self.retry_shipment()
    
    puts "Retrying shipment order ..."
    @shipment.retry(@auth_obj, get_pb_tx_id(), @shipment_orig_tx_id) 
  end
  
  # submit a shipment cancellation request
  # underlying API: DELETE /shipments/{shipmentId}
  def self.cancel_shipment()
    
    puts "Canceling shipment order ..." 
    cancel_result = @shipment.cancel(@auth_obj, @shipment_orig_tx_id, 
                                     @shipment.rates[0].carrier)
    puts "   status: " + cancel_result["status"]
  end

  # create a manifest
  # underlying API: POST /manifests
  def self.create_manifest()

    puts "Creating manifest ..."
    @manifest = PBShipping::Manifest.new( {
      :carrier => @tracking.carrier, 
      :submissionDate => Time.now.utc.strftime("%Y-%m-%d"),
      :parcelTrackingNumbers => [@shipment.parcelTrackingNumber],
      :fromAddress => @shipment.fromAddress
    } )
    @manifest_orig_tx_id = get_pb_tx_id()
    @manifest.create(@auth_obj, @manifest_orig_tx_id)
    puts "   manifest tracking number is " + @manifest.manifestTrackingNumber
    puts "   manifest id is " + @manifest.manifestId
  end

# reputs a manifest
# underlying API: GET /manifests/{manifestId}
  def self.reprint_manifest()
    
    puts "Repringing manifest ..."
    
    @manifest.reprint(@auth_obj)
    puts "   reprinted manifestId is " + @manifest.manifestId
  end

  # retry a mainfest
  # Underly API: GET /manifests
  def self.retry_manifest()
    
    puts "Retrying manifest request ..."
    @manifest.retry(@auth_obj, get_pb_tx_id(),  @manifest_orig_tx_id)    
    puts "   manifest id is " + @manifest.manifestId
  end

  # get tracking information
  # Underlying API: GET /tracking/{trackingNumber}
  def self.get_tracking_update()
        
    puts "Get tracking status ..."
    @tracking = PBShipping::Tracking.new( { :trackingNumber => @shipment.parcelTrackingNumber } )
    begin
        @tracking.updateStatus(@auth_obj)        
    rescue => e
      case e
      when PBShipping::ApiError 
        if PBShipping::configuration[:is_production] == false
          puts "   no tracking information in sandbox environment"
          return
        end
        raise e
      end
    end
    puts "   status = " + _tracking.status
  end

  # querying for a transaction report
  # Underlying API: GET /
  def self.get_transaction_report()
    
    puts "Retrieving transaction report ..."
    params = {}
    params[:merchantId] = @merchant.postalReportingNumber
    report = PBShipping::Developer.new({:developerId => @dev_id}).getTransactionReport(
      @auth_obj, params)
    puts "   First few entries ..."
    i = 0
    for next_row in report.content
      txn = PBShipping::TransactionDetails.new(next_row)
      txn_detail = "      id: " + txn.transactionId
      txn_detail += " type: " + txn.transactionType
      puts txn_detail
    end
  end
  
  # navgiate through different steps in shipping workflow                              
  def self.shipping_workflow()
    
    begin

      initialize_info()
      
      choose_environment()
      
      authenticate()
      
      check_carrier_supported_countries()
      
      # choose appropriate calls for individual or bulk account mode
      manage_individual_mode_merchant()
      #manage_bulk_mode_merchant()
      
      verify_addresses()
      
      prepare_shipment()
      create_and_purchase_shipment()
      reprint_shipment()
      retry_shipment()
      
      get_tracking_update()

      create_manifest()
      reprint_manifest()
      retry_manifest()
      
      get_transaction_report()
      
      cancel_shipment()
        
    rescue => e
      if e.is_a?(PBShipping::ApiError) && e.error_info != nil
        puts e.message
        puts e.error_info
      else
        puts "hit an exception"
        puts e
      end
    end
  end
end

PBShippingTutorial::shipping_workflow()