# encoding : utf-8

require 'tools/quality_tools/quality_tool'
require 'tools/base_rest'

module MGT
  class SonarQubeTool
    include BaseREST
    include MGT::QualityTool

    def initialize args
      super(args)
      @url = URI(args.URL)
      @tool_name = 'Sonarqube'
    end

    ##
    # check for connecting with incoming configuration parameters. Also check for server side response
    def test_connection
      path = @project ? "/api/resources?resource=#{@project}" : '/api/resources'
      try(path)
    end

    ##
    # method return statistics for project(s) from SonarQube server
    def get_statistics
      output_data = [['Project name', 'Lines of Code', 'Duplicated Lines', 'Blocked Violations', 'Critical Violations', 'Major Violations', 'High Priority Code Violations']]
      sonar_dashboard_information.each do |item|
        output_data << item.to_a
      end
      output_data << []
    end


    private

    ##
    # fetching information from SonarQube

    def sonar_dashboard_information
      path = path_with_project_name
      all_data = parse_response(send_GET_request(path).body)
      all_data.map do |item|
        MGT::SonarStructure.new(
          *argument_collector(item)
        )
      end
    end

    ##
    # method return path for particular project or path without project
    def path_with_project_name
      if @project
        "/api/resources?resource=#{@project}&metrics=ncloc,duplicated_lines,blocker_violations,critical_violations,major_violations"
      else
        '/api/resources?metrics=ncloc,duplicated_lines,blocker_violations,critical_violations,major_violations'
      end
    end

    ##
    # method return only needed elements
    def argument_collector item
      arr = []
      arr << item['name']
      item['msr'].each {|el| arr << el['val'].to_i}
      arr << arr.last(3).reduce(:+)
      arr
    end
  end

  ##
  # class create basic structure for Sonar dashboard information output
  class SonarStructure < Struct.new :project_name, :lines_of_code, :duplicated_lines, :blocker, :critical, :major, :hight_priority_violations
  end
end