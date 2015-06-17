# encoding: utf-8

require 'base64'
require 'json'
require 'net/http'
require 'uri'
require 'net/http/digest_auth'

require 'tools/code_review_tools/code_review_tool'


##
# This class represent fetching data from Review Board system.

module MGT
  class ReviewBoardTool
      include MGT::CodeReviewTool
        attr_accessor :user

        def initialize args
          super(args)
          @rb_url = URI(args.URL)
          @tools_name = 'Review Board'
        end

        ##
        # check for connection with incoming configuration parameters
        def test_connection 

          begin
            response = send_my_own_request('/api/review-requests/')

            if response.code == '401' && response.msg == 'UNAUTHORIZED'
              return 'Please, check your credentials to Review Board system'
            elsif response.code == '502'
              return 'Something going wrong on Review Board server side. Please, try later.'
            end

            rescue Errno::ECONNREFUSED
              return "Can't get connection to ReviewBoard url -  #{@url} - Connection refused"
            rescue Errno::ETIMEDOUT
              return "Can't get connection to ReviewBoard url -  #{@url} -  Connection timed out"
          end
          nil
        end

        ##
        # method return all commit hashes, which status was set to 'Submitted'
        def array_of_revisions
          str_for_request = "/api/review-requests/?status=submitted&timetime-added-from=#{@sprint_start_date}&time-added-to=#{@sprint_end_date}"
          parse_response(send_my_own_request(str_for_request).body)['review_requests'].map{|el| el['commit_id']}.uniq
        end

        private

        ##
        # method return all review requests from Review Board

        def take_all_review_requests opt
          res = Net::HTTP.start(@rb_url.hostname, @rb_url.port) do |http|
            request = Net::HTTP::Get.new('/api/review-requests/')
            request.basic_auth @username, @passwword
            http.request request
          end
          parse_response(res.body)['review_requests']
        end

        ##
        # ------ Some strict example, for changing previous ^ method ))
        def send_my_own_request path
          http = Net::HTTP.new(@rb_url.hostname, @rb_url.port)
          http.request_get(path, initheader = {'Contenttype' => 'application/json', 'Authorization' => create_my_authorization_token(@username, @password)} )
        end

        ##
        # create authorization token for HTTP header
        def create_my_authorization_token name, value
          'Basic ' + Base64.encode64("#{name}:#{value}")
        end

        ##
        # parsing response object to JSON format
        def parse_response response
          JSON.parse(response)
        end

        ##
        # method return extra information about current user
        def user_extra_information login
          self.user = parse_response(send_my_own_request("/api/users/#{login['title']}/").body)['user']
        end

        ##
        # method return extra information about current review request
        def changes_extra_information id
          parse_response(send_my_own_request("/api/review-requests/#{id}/changes/").body)
        end

        ##
        # method return diff context for current review request
        def diff_context_extra_information id
          parse_response(send_my_own_request("/api/review-requests/#{id}/diff-context/").body)
        end

        ##
        # method return differences for review request
        def differences id
          parse_response(send_my_own_request("/api/review-requests/#{id}/diffs/").body)
        end

        ##
        # return information about target people

        def target_people_iterating arr
          arr.map do |person|
            user_extra_information(person)
            fullname_join_email
          end
        end

        ## method return joined string with fullname and email
        def fullname_join_email
          ob = self.user
          ob['fullname'] + ' -- ' + ob['email']
        end


        ##
        # method-helper return some method from object if value exists
        def return_value_unless_object_nil obj, key
          obj[key] if obj
        end

        ##
        # execute method from object if object exists.
        def execute_method_unless_obj_nil method, obj
          self.send(method, obj) if obj
        end

        ##
        # return fullname and email to output line object
        def fullname_and_email person
          %w(fullname email).map do |key|
            return_value_unless_object_nil(person, key).to_s
          end
        end

        ##
        # collect all information to one object
        def argument_collector item
          submitter = execute_method_unless_obj_nil(:user_extra_information, item['links']['submitter'])
          arr = fullname_and_email(submitter)
          %w(summary id description time_added branch blocks depends_on issue_dropped_count issue_resolved_count ship_it_count status).each do |key|
            arr << return_value_unless_object_nil(item, key)
          end
          #  in this place you should push diff and other values, which we can fetch with extra requests and from configured systems of version control
          4.times { arr.push("") }

          arr << execute_method_unless_obj_nil(:target_people_iterating, item['target_people'])
        end
  end
end