module PBShipping
  class Shipment < ShippingApiResource
    
    # 
    # MANAGING RATES AND SHIPMENTS
    # API: POST /rates
    # API signature: post/rates
    #
    # Rate a shipment before a shipment label is purchased and printed.
    #
    # By default, the returned result would overwrite the current state 
    # of the object. To avoid overwriting, set the input argument 
    # overwrite to False and a copy of the result would be generated and
    # returned instead      
    #       
    def getRates(auth_obj, txid, includeDeliveryCommitment=nil, extraHdrs=nil)
      hdrs = { PBShipping::txid_attrname => txid } 
      if extraHdrs != nil
        hdrs.update(extraHdrs)
      end
      if includeDeliveryCommitment == nil
        params = { :includeDeliveryCommitment => false }            
      else
        params = { :includeDeliveryCommitment => includeDeliveryCommitment }     
      end      
      api_sig = "post/rates"
      api_version = PBShipping::get_api_version(api_sig)
      api_path = "/rates"
      json_resp = PBShipping::api_request(
        auth_obj, :post, api_version, api_path, hdrs, params, self)
      rate_list = []
      json_resp[:rates].each { |rate| rate_list << Rate.new(rate) }
      return rate_list        
    end

    # 
    # MANAGING RATES AND SHIPMENTS
    # API: POST /shipments/
    # API signature: post/shipments
    #
    # Create a shipment and purchase a shipment label.
    #     
    def createAndPurchase(auth_obj, txid, includeDeliveryCommitment=nil, 
      extraHdrs=nil, overwrite=true)
      hdrs = { PBShipping::txid_attrname => txid }
      if extraHdrs != nil
        hdrs.update(extraHdrs)      
      end
      if includeDeliveryCommitment == nil
        params = { :includeDeliveryCommitment => false }            
      else
        params = { :includeDeliveryCommitment => includeDeliveryCommitment }     
      end  
      api_sig = "post/shipments"
      api_version = PBShipping::get_api_version(api_sig)
      api_path = "/shipments"
      json_resp = PBShipping::api_request(
        auth_obj, :post, api_version, api_path, hdrs, params, self)
      if overwrite == true 
        self.update(json_resp)
        self
      else
        Shipment.new(json_resp)
      end
    end
 
    # 
    # MANAGING RATES AND SHIPMENTS
    # API: GET /shipments/{shipmentId}
    # API signature: get/shipments/...
    #
    # Reprint a shipment label. 
    # Note that the number of reprints of a shipment label will be scrutinized 
    # and restricted.
    #
    # By default, the returned result would overwrite the current state 
    # of the object. To avoid overwriting, set the input argument 
    # overwrite to False and a copy of the result would be generated and
    # returned instead      
    #    
    def reprintLabel(auth_obj, overwrite=true)
      if self.key?(:shipmentId) == false
        raise MissingResourceAttribute.new(:shipmentId)      
      end
      api_sig = "get/shipments/..."
      api_version = PBShipping::get_api_version(api_sig)
      api_path = "/shipments/" + self[:shipmentId]
      json_resp = PBShipping::api_request(
        auth_obj, :get, api_version, api_path, {}, {}, {})
      if overwrite == true 
        self.update(json_resp)
        self
      else
        Shipment.new(json_resp) 
      end       
    end
    
    def self.reprintLabelByShipmentId(auth_obj, shipmentId)
      Shipment.new({:shipmentId => shipmentId}).reprintLabel(auth_obj)
    end

    # 
    # MANAGING RATES AND SHIPMENTS
    # API: GET /shipments?originalTransactionId
    # API signature: get/shipments
    #
    # Retry a shipment that was previously submitted with no successful response.
    #
    # By default, the returned result would overwrite the current state 
    # of the object. To avoid overwriting, set the input argument 
    # overwrite to False and a copy of the result would be generated and
    # returned instead      
    #         
    def retry(auth_obj, txid, originalTxid, overwrite=true)
      hdrs = { PBShipping::txid_attrname => txid }
      params = {:originalTransactionId => originalTxid}
      api_sig = "get/shipments"
      api_version = PBShipping::get_api_version(api_sig)
      api_path = "/shipments"
      json_resp = PBShipping::api_request(
        auth_obj, :get, api_version, api_path, hdrs, params, {})   
      if overwrite == true 
        self.update(json_resp)
        self
      else
        Shipment.new(json_resp)   
      end     
    end
    
    def self.retryByTransactionId(auth_obj, txid, originalTxid)
      Shipment.new().retry(auth_obj, txid, originalTxid)
    end

    # 
    # MANAGING RATES AND SHIPMENTS
    # API: DELETE /shipment/{shipmentId}
    # API signature: delete/shipments/...
    #
    # Cancel/void a shipment, and submit the shipment label for refund.
    #       
    def cancel(auth_obj, txid, carrier, cancelInitiator=nil)
      if self.key?(:shipmentId) == false
        raise MissingResourceAttribute.new(:shipmentId)
      end
      hdrs = { PBShipping::txid_attrname => txid }
      payload = { :carrier => carrier }
      if cancelInitiator != nil
        payload[:cancelInitiator] = cancelInitiator
      end
      api_sig = "delete/shipments/..."
      api_version = PBShipping::get_api_version(api_sig)
      api_path = "/shipments/" + self[:shipmentId]
      json_resp = PBShipping::api_request(
        auth_obj, :delete, api_version, api_path, hdrs, nil, payload) 
      ApiObject.new(json_resp)
    end
    
    def cancelByShipmentId(auth_obj, txid, shipmentId, carrier, cancelInitiator=nil)
      Shipment.new({:shipmentId => shipmentId}).cancel(
        auth_obj, txid, carrier, cancelInitiator)
    end
  end
  class ShipmentOptions < ShippingApiResource
  end
  class ShipmentLabel < ShippingApiResource
  end  
end