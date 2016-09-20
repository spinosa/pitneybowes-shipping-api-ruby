module PBShipping
  class Tracking < ShippingApiResource
    
    #
    # TRACKING
    # API: GET /tracking/{trackingNumber}
    # API signature: get/tracking/...
    #
    # Shipment labels that are printed using the Pitney Bowes APIs are 
    # automatically tracked and their package status can be easily retrieved 
    # using this implementation of the GET operation.
    #    
    def updateStatus(auth_obj) 
      if self.key?(:trackingNumber) == false
        raise MissingResourceAttribute.new(:trackingNumber)
      end
      if self.key?(:packageIdentifierType) == false
        self[:packageIdentifierType] = "TrackingNumber"
      end
      if self.key?(:carrier) == false
        self[:carrier] = "USPS"
      end
      params = {
        :carrier => self[:carrier],
        :packageIdentifierType => self[:packageIdentifierType]
      }
      api_sig = "get/tracking/..."
      api_version = PBShipping::get_api_version(api_sig)
      api_path = "/tracking/" + self[:trackingNumber]
      json_resp = PBShipping::api_request(
        auth_obj, :get, api_version, api_path, {}, params, {})
      self.update(json_resp)
    end
  end
end