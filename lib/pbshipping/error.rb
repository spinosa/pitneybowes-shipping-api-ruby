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
# File: error.rb
# Description: class encapsulating shipping api exceptions/errors.
# 

module PBShipping
  class ApiError < StandardError
    attr_reader :message, :http_code, :http_body, :error_info
    def initialize(message, http_code=nil, http_body=nil)
      @message = message
      @http_code = http_code
      @http_body = http_body
      @error_info = []
      if http_body != nil 
        begin 
          json_error = PBShipping::json_parse(http_body)
        rescue => e
        end
        if json_error.is_a?(Array)
          for next_err in json_error
            if next_err.key?(:key) == true 
              @error_info << {
                :errorCode => next_err[:key], 
                :message => next_err[:message]
              }
            elsif next_err.key?(:errorCode) == true
              @error_info << {
                :errorCode => next_err[:errorCode], 
                :message => next_err[:message]
              }
            end
          end
        elsif json_error.is_a?(Hash) && json_error.key?(:errors)
          for next_err in json_error[:errors]
            @error_info << {
              :errorCode => next_err[:errorCode],
              :message => next_err[:errorDescription]
            }
          end
        end
      end
    end

    def to_s
      if http_body != nil
        msg = @message + " " + http_body.to_s
      else
        msg = @message
      end
      return msg
    end
  end
  class AuthenticationError < ApiError
  end
  class MissingResourceAttribute < ApiError
    def initialize(missing_attr)
      super("Attribute " + missing_attr.to_s + " is missing")
    end
  end
end
