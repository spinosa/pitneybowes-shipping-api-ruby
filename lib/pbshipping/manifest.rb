module PBShipping
  class Manifest < ShippingApiResource
 
    # 
    # MANAGING MANIFESTS
    # API: POST /manifests
    # API signature: post/manifests
    #
    # Create a USPS scan form
    #
    # By default, the returned result would overwrite the current state 
    # of the object. To avoid overwriting, set the input argument 
    # overwrite to False and a copy of the result would be generated and
    # returned instead      
    #
    def create(auth_obj, txid, overwrite=true)
      if self.key?(:carrier) == false
        raise MissingResourceAttribute.new(:carrier)
      elsif self.key?(:parcelTrackingNumbers) == false
        raise MissingResourceAttribute.new(:parcelTrackingNumbers)
      elsif self.key?(:submissionDate) == false
        raise MissingResourceAttribute.new(:submissionDate)
      elsif self.key?(:fromAddress) == false
        raise MissingResourceAttribute.new(:fromAddress)
      end
      hdrs = { PBShipping::txid_attrname => txid }
      payload = {
        :carrier => self[:carrier],
        :parcelTrackingNumbers => self[:parcelTrackingNumbers],
        :submissionDate => self[:submissionDate],
        :fromAddress => self[:fromAddress]
      }
      api_sig = "post/manifests"
      api_version = PBShipping::get_api_version(api_sig)
      api_path = "/manifests"
      json_resp = PBShipping::api_request(
        auth_obj, :post, api_version, api_path, hdrs, {}, payload)
      if overwrite == true
        self.update(json_resp)
        self
      else
        Manifest.new(json_resp)
      end
    end

    # 
    # MANAGING MANIFESTS
    # API: GET /manifests/{manifestId}
    # API signature: get/manifests/...
    #
    # Reprint the USPS scan form
    #
    # By default, the returned result would overwrite the current state 
    # of the object. To avoid overwriting, set the input argument 
    # overwrite to False and a copy of the result would be generated and
    # returned instead  
    #    
    def reprint(auth_obj, overwrite=true)
      if self.key?(:manifestId) == false
        raise MissingResourceAttribute.new(:manifestId)
      end
      api_sig = "get/manifests/..."
      api_version = PBShipping::get_api_version(api_sig)
      api_path = "/manifests/" + self[:manifestId]
      json_resp = PBShipping::api_request(
        auth_obj, :get, api_version, api_path, {}, {}, {})
      if overwrite == true
        self.update(json_resp)
        self
      else
        Manifest.new(json_resp)   
      end     
    end
    
    def self.reprintById(auth_obj, manifestId)
      Manifest.new({:manifestId => manifestId}).reprint(auth_obj)
    end

    # 
    # MANAGING MANIFESTS
    # API: GET /manifests
    # API signature: get/manifests/
    #
    # Retry a manifest request that was previously submitted with no successful 
    # response
    #
    # By default, the returned result would overwrite the current state 
    # of the object. To avoid overwriting, set the input argument 
    # overwrite to False and a copy of the result would be generated and
    # returned instead      
    #    
    def retry(auth_obj, txid, originalTxid, overwrite=true)
      hdrs = { PBShipping::txid_attrname => txid }
      params = { :originalTransactionId => originalTxid }
      api_sig = "get/manifests"
      api_version = PBShipping::get_api_version(api_sig)
      api_path = "/manifests"
      json_resp = PBShipping::api_request(
        auth_obj, :get, api_version, api_path, hdrs, params, {})
      if overwrite == true
        self.update(json_resp)
        self
      else
        Manifest.new(json_resp)      
      end  
    end
    
    def self.retryByTransactionId(auth_obj, txid, originalTxid)
      Manifest.new().retry(auth_obj, txid, originalTxid)
    end
  end
end