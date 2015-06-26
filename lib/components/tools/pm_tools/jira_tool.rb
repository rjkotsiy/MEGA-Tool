# encoding: utf-8

require 'jira'
require 'tools/pm_tools/pm_tool'

module MGT
  class JiraTool
    include MGT::PmTool

    attr_reader :access_client, :basic_query_params 

    def initialize(args)
      @project = args.project

      @employees = string_or_array(args, :employees, :downcase)
      @statuses = string_or_array(args, :statuses)
      @priorities = string_or_array(args, :priorities)
      @issue_types = string_or_array(args, :issue_types)
      super(args)

      @access_client = jira_client
      @basic_query_params = {}
    end

    ##
    # check connection to Jira with incoming parameters, return some notification messages
    def test_connection

      error = nil

      @basic_query_params = {
        :fields => {},
        :start_at => 0,
        :max_results => 1000000000
      }

      begin
        response = @access_client.get('/secure/Dashboard.jspa')

        if response.code == '502'
          error = 'Something going wrong in JIRA server side. Please, try later.'
        elsif response.code == '403'
          error = 'Please, check your access rights to JIRA.'
        end
      rescue JIRA::HTTPError
        error = 'Please check your credentials or right URL address for Jira'
      rescue  
        error = 'Unrecognized error while connecting to Jira server'        
      end

      error

    end

    ##
    # this method convert incoming JIRA data structure to array, depend on incoming issues.

    def get_all_information
      result = [['Employee','TaskId - uniqID', 'Status', 'Issue Type' ,'Priority', 'Velocity (SP)', 'Planed estimate(hours)', 'Actual effort(hours)']]
      fetching.each do |issue|
        result.push(issue.to_a)
      end
      result
    end

    ##
    # method return Know Defects Estimate
    def known_defects_estimate
      jql_for_defects_estimate = "project = #{@project} and (type = Defect OR type = Sub-Defect) and 'Defect Type' != 'Technical Debt' and created >= '#{@sprint_start_date}' and created <= '#{@sprint_end_date}' and status was not Closed"
      def_dept_helper
      known_defect_estimate = count_estimation(jql_for_defects_estimate)
      output_result = []
      output_result << ["Known Defects Estimate - #{period_helper}", 'Hours', 'Points']
      output_result << ['', "#{known_defect_estimate[0]}", "#{known_defect_estimate[1]}"]
      output_result << []
    end

    ##
    # method return Technical Debt Estimate
    def technical_debt_estimate
      jql_for_debt_estimate = "project = #{@project} and (type = Defect OR type = Sub-Defect) and 'Defect Type' = 'Technical Debt' and created >= '#{@sprint_start_date}' and created <= '#{@sprint_end_date}' and status != Closed"
      def_dept_helper
      known_techdept_estimate = count_estimation(jql_for_debt_estimate)
      out_result = []
      out_result << ["Technical Debt Estimate - #{period_helper}", 'Hours', 'Points']
      out_result << ['', "#{known_techdept_estimate[0]}", "#{known_techdept_estimate[1]}"]
      out_result << []
    end

    ##
    # method return Technial Debt Backlog Size
    def technical_backlog_size
      jql_for_debt_backlog = "project = #{@project} and type in (Defect, Sub-Defect) and 'Defect Type' = 'Technical Debt' and created <= '#{@sprint_end_date}' and status != Closed"
      def_dept_helper
      output_result = []
      output_result << ["Technical Debt Backlog Size", 'Value']
      output_result << ['', "#{issues_by_jql(jql_for_debt_backlog).size}"]
    end

    private

    ##
    # setter basic parameters for defects statistic
    def def_dept_helper
      @basic_query_params[:fields] = ['timeoriginalestimate', 'customfield_10002']
    end

    ##
    # helper method for output
    def period_helper
      "#{@sprint_start_date }  -  #{@sprint_end_date}"
    end

    ##
    # get all data from current project

    def fetching
      jql_string = add_range_to_jql(add_project_name_to_jql(initializing_jql_string))
      # customfield_11130 - sprint information stored here(Jira-SoftServe), add this field if you want fetch sprint information
      @basic_query_params[:fields] = ['assignee','key','status','issuetype','priority','customfield_10002','timeoriginalestimate','aggregatetimespent']

      arr = issues_by_jql(jql_string)
      arr.map do |issue|
        MGT::JiraStructure.new(
            *argument_composer(issue)
        )
      end
    end

    ##
    # method create jira client

    def jira_client
      options = {
          :username     => @username,
          :password     => @password,
          :site         => @url,
          :context_path => "",
          :auth_type    => :basic,
          :use_ssl      => true
      }
      JIRA::Client.new(options)
    end

    ##
    # check for correct project name from incoming parameters. Provide some notification message if project does not exists.

    def check_for_correct_jira_project error
      error_string = nil
      if error != nil
        begin
          @access_client.Project.find(@project)
        rescue  JIRA::HTTPError
          error_string = 'Please, check JIRA Project Name'
        end
      end
      error_string
    end

    ##
    # method separate values from array of incoming configuration fields to string, which will pass to jql string. This method wee need according to Jira jql string format. Parameters, which can be in range of possible parameter should be like strings. Example: in ('value1', 'value2')

    def array_to_string arr, type
      if arr.size == 1
        "#{type}='#{arr[0]}'"
      else
        "#{type} in ('#{arr.join("','")}')"
        # "#{type} in (#{arr.map { |i| "'" + i.to_s + "'" }.join(",")}) "
      end
    end

    ##
    # added new parameters to jql string

    def creating_jql_string arr, str, type
      if !arr.empty? && str.empty?
        array_to_string arr, type
      elsif !arr.empty? && !str.empty?
        " AND #{array_to_string(arr, type)}"
      end
    end

    ##
    # add project name to jql string

    def add_project_name_to_jql jql_string
      unless jql_string.empty?
        jql_string.insert(0, "project=#{@project} AND ")
      else
        "project=#{@project}"
      end
    end

    ##
    # add date range for issues to jql string
    def add_range_to_jql str
      str << " and created >= '#{@sprint_start_date}' and created <= '#{@sprint_end_date}'"
    end


    ##
    # initialize new jql string.

    def initializing_jql_string
      jql_string = ''
      jql_string << array_to_string(@employees, 'assignee') unless @employees.empty?
      [[@statuses, 'status'], [@priorities, 'priority'], [@issue_types, 'issuetype']].each do |param, name|
        jql_string << creating_jql_string(param, jql_string, name) unless param.empty?
      end
      jql_string
    end

    ##
    # method return issues by passing jql to client

    def issues_by_jql jql
      @access_client.Issue.jql(jql, self.basic_query_params)
    end

    def argument_composer(issue)
      # store = sprint_info(issue)
      [
          return_method_from_obj_if_obj_not_nil(issue.assignee, :displayName),
          "#{ issue.key + " - " + issue.id }",
          return_method_from_obj_if_obj_not_nil(issue.status),
          return_method_from_obj_if_obj_not_nil(issue.issuetype),
          return_method_from_obj_if_obj_not_nil(issue.priority),
          # store[0],
          # time_parsing(store[1]),
          # time_parsing(store[2]),
          return_method_from_obj_if_obj_not_nil(issue.customfield_10002, :to_s),
          division_if_not_nil(issue.timeoriginalestimate),
          division_if_not_nil(issue.aggregatetimespent)
      ]
    end

    ##
    # return sprint info
    def sprint_info issue
      helper_for_parsing_sprint_info(issue.customfield_11130, [2, 3, 4])
    end
    ##
    # return time value in hours.

    def division_if_not_nil item
      if item
        item / 3600
      else
        0
      end
    end

    ##
    # return method from object if object exists.

    def return_method_from_obj_if_obj_not_nil obj, method=:name
      obj.send(method) if obj
    end

    ##
    # return sprint information with parsing incoming string if value exists.

    def helper_for_parsing_sprint_info obj, arr
      arr.map do |field_num|
        "#{obj[0].split(',')[field_num].split("=")[1]}" if obj
      end
    end

    ##
    # convert time to human readable format.

    def time_parsing str
      Time.parse(str) if str && str != "<null>"
    end

    ##
    # check for correct project name from incoming configuration file. Provide some notification message if project does not exists.

    ##
    # method return total count of estimate
    def count_estimation jql
      array_of_issues = issues_by_jql(jql)
      hash = array_of_issues.inject({}) do |result, el|
        result[el.timeoriginalestimate || "time didn't specified at #{el.key}"] = el.customfield_10002.to_f
        result
      end
      sum_of_estimation = hash.each_key.inject(0) {|sum, item| sum + item.to_i}
      sum_of_story_points = hash.each_value.reduce(0, :+)
      [ division_if_not_nil(sum_of_estimation) ,sum_of_story_points ]
    end
  end

  ##
  # class create basic structure for Jira.
  # todo: add fields :iteration, :iteration_start, :iteration_stop if you use SoftServe Jira store format

  class JiraStructure < Struct.new :employee, :taskId, :status, :issueType, :priority,  :velocitySP, :plannedEstimate, :actualEffort
  end
end