module PBShipping
  class Developer < ShippingApiResource

    # 
    # CLIENT LIBRARY SPECIFIC
    # API: GET /developers/{developerId}
    # API signature: get/developers/...
    # 
    # Query for developer account attributes
    #
    def refresh(auth_obj)
      if self.key?(:developerId) == false
        raise MissingResourceAttribute.new(:developerId)
      end
      api_sig = "get/developers/.."
      api_version = PBShipping::get_api_version(api_sig)
      api_path = "/developers/" + self[:developerId]
      json_resp = PBShipping::api_request(auth_obj, :get, api_version, api_path, {}, {}, {})
      self.update(json_resp) 
    end
        
    #
    # MANAGING MERCHANTS
    # API: GET /developers/{developerId}/merchants/emails/{emailId}/
    # API signature: get/developers/.../merchants/emails/...
    #
    # Register your merchants or shippers, if you have signed up for the 
    # individual account payment model.
    #
    # This method allows you to retrieve the merchant ID and related
    # information based on the Email ID they used while registering, 
    # so that you can request transactions on their behalf.  
    #  
    def registerMerchantIndividualAccount(auth_obj, emailid)
      if self.key?(:developerId) == false
        raise MissingResourceAttribute.new(:developerId)
      end
      api_sig = "get/developers/.../merchants/emails/..."
      api_version = PBShipping::get_api_version(api_sig)
      api_path = "/developers/" + self[:developerId]
      api_path += "/merchants/emails/" + emailid + "/"
      Merchant.new(PBShipping::api_request(
        auth_obj, :get, api_version, api_path, {}, {}, {}))
    end

    #
    # CLIENT LIBRARY SPECIFIC
    # API: GET /developers/{developerId}/merchants/emails/{emailId}/
    # API signature: get/developers/.../merchants/emails/...
    # 
    # Query for merchant details using merchant's email address if developer
    # is operating in bulk mode
    #
    def getMerchantBulkAccount(auth_obj, emailid)
      # use the same underlying REST call
      return self.registerMerchantIndividualAccount(auth_obj, emailid)
    end
        
    #
    # MANAGING MERCHANTS
    # API: POST /developers/{developerId}/merchants/registration
    # API signature: post/developers/.../merchants/registration
    #   
    # Register your merchants or shippers, if you have signed up for the 
    # bulk account payment model.
    # 
    # This method allows you to retrieve the merchant ID and related
    # information, so that you can request transactions on their behalf. 
    #    
    def registerMerchantBulkAccount(auth_obj, address)
      if self.key?(:developerId) == false
        raise MissingResourceAttribute.new(:developerId)
      end
      api_sig = "post/developers/.../merchants/registration"
      api_version = PBShipping::get_api_version(api_sig)
      api_path = "/developers/" + self[:developerId]
      api_path += "/merchants/registration"
      Merchant.new(PBShipping::api_request(
        auth_obj, :post, api_version, api_path, {}, {}, address))
    end
 
    #
    # MANAGING MERCHANTS
    # API: GET /ledger/developers/{developerId}/transactions/reports
    # API signature: get/ledger/developers/.../transactions/reports
    #
    # Retrieve all transactions based on the given input parameters   
    #      
    def getTransactionReport(auth_obj, params)
      if self.key?(:developerId) == false   
        raise MissingResourceAttribute.new(:developerId)
      end  
      api_sig = "get/ledger/developers/.../transactions/reports"
      api_version = PBShipping::get_api_version(api_sig)
      api_path = "/ledger/developers/" + self[:developerId]
      api_path += "/transactions/reports"
      ApiObject.new(PBShipping::api_request(
        auth_obj, :get, api_version, api_path, {}, params, {}))
    end
  end
end