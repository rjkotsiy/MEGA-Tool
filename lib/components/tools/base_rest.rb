# encoding : utf-8

require 'json'
require 'net/http'
require 'uri'
require 'net/http/digest_auth'


module MGT

  ##
  # class collect repeated methods for using REST API

  module BaseREST

    protected

    def try(path)
      error = nil
      begin
        response = send_GET_request(path)
        resp_code = response.code
        if resp_code == '401' && response.msg.capitalize == 'Unauthorized'
          error =  "Please, check your credentials to #{@tool_name} system"
        elsif resp_code == '502'
          error =  "Something going wrong on #{@tool_name} server side. Please, try later."
        elsif resp_code == '404'
          error =  "Project  - #{@project} - is not found in #{@tool_name}."
        end
      rescue Errno::ECONNREFUSED
        error =  "Can't get access to #{@tool_name} at #{@url} - Connection refused"
      rescue Errno::ETIMEDOUT
        error = "Can't get access to #{@tool_name} at #{@url} -  Connection timed out"
      rescue 
        error = "Unknown service error #{@tool_name} at #{@url}"
      end
      error
    end

    ##
    # method send GET request to server side

    def send_GET_request path
      Net::HTTP.start(@url.hostname, @url.port, :use_ssl => @url.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
        request = Net::HTTP::Get.new(path)
        request.basic_auth @username, @password
        request['Accept'] = 'application/json'
        http.request request
      end
    end

    ##
    # parsing response object to JSON format
    def parse_response response
      JSON.parse(response)
    end
  end
end