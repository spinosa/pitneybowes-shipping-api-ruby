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
# File: authentication.rb
# Description: handling authentication tasks for subsequent shipping api calls.
# 

module PBShipping
  class AuthenticationToken
    attr_accessor :api_key, :api_secret, :access_token, :auth_info
    
    def initialize(api_key, api_secret)
      @api_key = api_key
      @api_secret = api_secret
      @access_token = nil
      @auth_info = nil
      refresh_token()
    end
    
    def refresh_token()
      @auth_info = PBShipping::authenticate_request(@api_key, @api_secret)
      @access_token = @auth_info[:access_token]
    end
  end
end