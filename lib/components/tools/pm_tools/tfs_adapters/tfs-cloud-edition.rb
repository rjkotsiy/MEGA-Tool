# encoding : UTF-8

require 'uri'
require 'net/http'
require 'net/https'
require 'tools/pm_tools/tfs_adapters/tfs_base'
##
# This class implements fetching data from TFS Cloud online system.

module MGT
    class TFSOnlineEdition < MGT::TFSBase

        ##
        # class constructor, initializing args
        def initialize args
          super (args)          
        end

        ##              
        # fetch work items from TFS project and provide some errors if exists
        def tfs_do_fetch
          @errors = nil
          workitems_ids = get_workitems_ids

          unless @errors == nil
            return @errors
          end 

          if workitems_ids.size == 0
            return @errors = 'No data has been returned from TFS, please check you fetching conditions and try again'
          end
          set_my_data(workitems_ids)

          @errors
        end


        private

        ## method send POST query to specified uri with necessary body
        def send_my_post_request data, uri
          Net::HTTP.start(uri.host, uri.port,
                          :use_ssl => uri.scheme == 'https',
                          :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
            request = Net::HTTP::Post.new uri.request_uri
            request.basic_auth @args.username, @args.password
            request.content_type = 'application/json'
            request.body = data.to_json
            http.request request
          end
        end

        ##
        # method send GET request to url
        def send_my_get_request uri
          Net::HTTP.start(uri.host, uri.port,
                          :use_ssl => uri.scheme == 'https',
                          :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
            request = Net::HTTP::Get.new uri.request_uri
            request.basic_auth @args.username, @args.password
            response = http.request request
            JSON.parse(response.body)
          end
        end

        ##
        # method set data to specified fields
        def set_my_data workitems_ids
          query_param = prepare_ids_query workitems_ids
          workitems = get_workitems_list (query_param)
          @work_items_hash = fetch_selected_workitems (workitems['value'])
        end

        ##
        # fetch data from local workitems hash and convert it to another hash structure
        # additionally make some calculation
        def fetch_selected_workitems workitems
          arr = []

          workitems.each do |value|
            hash_new = {}
            hash_new['id'] = value['id']
            fields = value['fields']
            hash_new['title'] = value.fetch('fields')['System.Title']
            hash_new['type'] = fields['System.WorkItemType']
            hash_new['assigned_to'] = fields['System.AssignedTo']
            hash_new['state'] = value.fetch('fields')['System.State']
            hash_new['estimate'] = fields['Microsoft.VSTS.Scheduling.Effort'] || value.fetch('fields')['Microsoft.VSTS.Scheduling.RemainingWork']
            hash_new['tags'] = fields['System.Tags'] || []

            defect_debt_backlog_size(hash_new, fields['System.CreatedDate'])
            arr << hash_new
          end

          {'workitems' => arr}
        end

        ##
        # method calculate metrics data(defects, debts, thieir size)
        def defect_debt_backlog_size item, created_at

          # we calculate all children estimate, with effort of bug,
          has_tag = item['tags'].include? @args.tags

          if created_at.to_datetime >= @args.sprint_start_date.to_datetime
            if has_tag
              @known_defect_techdebt_estimate += item['estimate']
            else
              @known_defect_estimate += item['estimate']
            end
          else
            if has_tag
              @techdebt_backlog_size += 1
            end
          end

        end

        ##              
        # get work items ids for desired project and iteration path
        def get_workitems_ids 
          project = @args.project
          post_data_query = {
            'query' =>
                  "Select [System.Id] 
                   From WorkItems WHERE
                   [System.TeamProject] = '#{project}' AND
                   ([System.WorkItemType] = 'Bug' OR [System.WorkItemType] = 'Task') AND 
                   [State] <> 'Done' AND [State] <> 'Removed' AND
                   [System.CreatedDate] <= '#{@args.sprint_end_date}'"
            }
          uri = URI( @args.URL + '/' + project + '/_apis/wit/wiql?api-version=1.0')

          begin
            response = send_my_post_request(post_data_query, uri)
            if response.code == '200'
              @hash_result = JSON.parse(response.body)
            elsif response_code == '401' && response_msg == 'UNAUTHORIZED'
              @errors = 'Please, check your credentials to TFS system'
            elsif response_code == '502'
              @errors = 'Something going wrong on TFS server side. Please, try later.'
            else
              @errors = 'Bad url or user has not been authenticated, also please check you project name'
            end
          rescue Errno::ECONNREFUSED
            @errors = "Can't get connection - Connection refused"
          rescue Errno::ETIMEDOUT
            @errors = "Can't get connection -  Connection timed out"
          end

          @hash_result['workItems']
        end


        ##              
        # get work items ids for desired project and iteration path
        def get_workitems_related_link_count source_id
          post_data_query = {'query' => "Select *  From WorkItemLinks Where Source.[System.Id] = '#{source_id}'"};
          uri = URI( @args.URL + '/' + @args.project + '/_apis/wit/wiql?api-version=1.0')
          response = send_my_post_request(post_data_query, uri)
          JSON.parse(response.body)['workItemRelations'].size
        end

      ##
      # method return work items from remote tfs
      def get_workitems_list workitems_query_param
        query_string = @args.URL + '/' + "/_apis/wit/workitems?#{workitems_query_param}&api-version=1.0"
        uri = URI(query_string)
        send_my_get_request(uri)
      end

      ##
      # method return sub_string for query
      def prepare_ids_query work_items_array
        'ids=' + work_items_array.map do |value|
            value['id']
        end.join(',')
      end
    end
end
