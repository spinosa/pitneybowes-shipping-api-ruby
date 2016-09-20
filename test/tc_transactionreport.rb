require 'bigdecimal'
require "test/unit"
require "pbshipping"
require_relative "test_util"

class TestTransactionReport < Test::Unit::TestCase

  def setup
    @auth_obj = PBShipping::AuthenticationToken.new(
      PBShippingTestUtil::api_key, PBShippingTestUtil::api_secret) 
    @developer = PBShippingTestUtil::setup_developer(@auth_obj)
    merchant, acct_num = PBShippingTestUtil::setup_merchant(
      @auth_obj, @developer)   
    @shipper_id = merchant.postalReportingNumber  
  end

  def teardown
  end
  
  def verifyAndPrintReport(report, query)
    puts "  Total matching records = " + report.totalElements.to_s
    puts "  Total number of pages = " + report.totalPages.to_s
    puts "  Current page number is " + report.number.to_s
    puts "  Page size is " + report.size.to_s
    puts "  Sort by " + report[:sort][0][:property]

    if report[:sort][0][:ascending] == true
      sort_dir = "asc"
    else
      sort_dir = "desc"
    end
    sort_info = report[:sort][0][:property] + "," + sort_dir
    assert_equal(sort_info, query[:sort])
    
    rate_benchmark = PBShippingTestUtil::check_shipment_rate(
      @auth_obj, @developer)

    for next_row in report.content
            txn = PBShipping::TransactionDetails.new(next_row)
            
            if (txn.transactionType.include?("POSTAL PRINT"))
              assert_equal(BigDecimal(txn.developerRateAmount, 3), BigDecimal(rate_benchmark, 3))
            end

            txn_detail = "      timestamp: " + txn.transactionDateTime
            txn_detail += " txid: " + txn.transactionId
            txn_detail += " type: " + txn.transactionType
            txn_detail += " rate: " + txn.developerRateAmount.to_s
            txn_detail += " balance: " + txn.shipperPostagePaymentAccountBalance.to_s
            puts txn_detail  
    end
  end

  def test_trasnsactionreport
    puts "Testing get transaction report  ..."
    
    # limit to past 28 days 
    time_now = Time.now.utc
    seven_days_ago = time_now - 28 * 60 * 60 * 24
    query = {:fromDate => seven_days_ago.iso8601, :toDate => time_now.iso8601}
    # limit to transactions originating from this test suite
    query[:transactionId] = "%%" + PBShippingTestUtil::test_suite_txid_prefix  + "%%"   
    # limit to test suite merchant
    query[:merchantId] = @shipper_id
    # sort according to transaction id in descending order
    query[:sort] = "transactionId,desc"

    # paging control can be configured through these parameters           
    # query[:page] = 0 # control the page to query for 
    # query[:size] = 20 # control the page size     
    report = @developer.getTransactionReport(@auth_obj, query)
    verifyAndPrintReport(report, query)  
  end

end