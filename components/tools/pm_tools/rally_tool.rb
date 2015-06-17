# encoding : utf-8
require 'rally_api'
require 'tools/pm_tools/pm_tool'

module MGT
  class RallyTool
    include MGT::PmTool
  
        def initialize(args)
          super(args)
        end

        ##
        # method check connections to Rally with incoming params
        def test_connection        
          begin
            @rally_client = rally_client
          rescue StandardError
            return 'Please check you config parameters for Rally system'
          end
          nil
        end

        ##
        # method return Defects Estimate
        def known_defects_estimate
          output_result = []
          output_result << ["Known Defects Estimate - #{period_helper}", 'Hours', 'Points']
          output_result << ['Technical Debt Estimate', calculate_points(result_by_query(technical_debt_query))] 
          out_result << []
        end

        ##
        # method return Technical Defects Estimate        
        def technical_debt_estimate
          out_result = []
          out_result << ["Technical Debt Estimate - #{period_helper}", 'Hours', 'Points']
          out_result <<['Technical Debt Estimate', calculate_points(result_by_query(technical_debt_query))] 
          out_result = []
        end

        ##
        # method return Technial Debt Backlog Size
        def technical_backlog_size
          output_result = []
          output_result << ["Technical Debt Backlog Size", 'Value']          
          output_result <<['Technical Debt Backlog Size', result_by_query(technical_dept_backlog_size).total_result_count]
          out_result << []
        end


        private

        ##
        # helper method for output
        def period_helper
          "#{@sprint_start_date }  -  #{@sprint_end_date}"
        end

        ##
        # method return basic headers
        def headers
          RallyAPI::CustomHttpHeader.new({:vendor => 'Vendor', :name => 'Custom Name', :version => '1.0'})
        end

        ##
        # method create basic configuration
        def rally_config
          config = {}
          config[:username]   = @username
          config[:password]   = @password
          config[:project]    = @project
          config[:workspace]  = @workspace
          config[:headers]    = headers
          config
        end

        ##
        # method return instance of rally_client
        def rally_client
          RallyAPI::RallyRestJson.new(rally_config)
        end

        ##
        # method return basic instance of query
        def query_object
          RallyAPI::RallyQuery.new()
        end

        ##
        # basic things for query
        def basic_query_things arr
          test_query = query_object
          test_query.type = "defect"
          test_query.project_scope_up = false
          test_query.project_scope_down = false
          test_query.page_size = 500
          test_query.project = {"_ref" => rally_client.rally_default_project.rally_object["_ref"]}
          test_query.query_string = test_query.build_query_segment(arr, 'and')
          test_query
        end

        ##
        # method create query for fetching all known_defect were was created during the sprint
        def known_defect_query
          basic_query_things(repeated_strings_params << "Tags.Name !contains #{@tags}")
        end

        ##
        # method create query for fetching Technical Debt Estimate were created during the sprint
        def technical_debt_query
          basic_query_things(repeated_strings_params << "Tags.Name contains #{@tags}")
        end

        def repeated_strings_params
          ["CreationDate >= #{@sprint_start_date}", "CreationDate <= #{@sprint_end_date}", 'State != Closed']
        end

        ##
        # method return query for fetching Technical Debt Backlog size
        def technical_dept_backlog_size
          basic_query_things(["CreationDate <= #{@sprint_start_date}", 'State != Closed', "Tags.Name contains #{@tags}"])
        end

        ##
        # method return all results from project by query
        def result_by_query query
          @rally_client.find(query)
        end

        ##
        # method calculate all points form returned result

        def calculate_points arr
          arr.inject(0) do |sum, item|
            if item.read.rally_object["PlanEstimate"]
              sum + item.read.rally_object["PlanEstimate"]
            else
              sum + 0
            end
          end
        end

  end
end
