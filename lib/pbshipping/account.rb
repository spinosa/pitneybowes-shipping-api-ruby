module PBShipping
  class Account < ShippingApiResource
    
    #
    # MANAGING MERCHANTS
    # API: GET /ledger/accounts/{accountNumber}/balance
    # API signature: get/ledger/accounts/.../balance
    #
    # Retrieve the account balance of a merchant account.   
    #    
    def getBalance(auth_obj)
      if self.key?(:accountNumber) == false
        raise MissingResourceAttribute.new(:accountNumber)
      end
      api_sig = "get/ledger/accounts/.../balance"
      api_version = PBShipping::get_api_version(api_sig)
      api_path = "/ledger/accounts/" + self[:accountNumber] + "/balance"
      json_resp = PBShipping.api_request(auth_obj, :get, api_version, api_path, 
                                         {}, {}, {})
      return ApiObject.new(json_resp)
    end
    
    def self.getBalanceByAccountNumber(auth_obj, accountNumber)
      return Account.new({:accountNumber => accountNumber}).getBalance(auth_obj)
    end
  end
end