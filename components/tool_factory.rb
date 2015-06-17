# encoding: utf-8
$: << LIB_PATH unless $:.include?(LIB_PATH)

require 'rbconfig'

Dir['lib/components/tools/**/*.rb'].each { |file| require (Dir.pwd + '/' + file) }

module MGT

  ##
  # class responsible for getting connection to specified tool
  class ToolFactory
    attr_reader :tools, :errors

    def initialize tools
      @tools = tools
      @errors = []
    end

    ##
    # method create tools list with worked connection for metrics
    def create
      connected_tools = []
      @tools.each do |tool|
        tool_obj = MGT::AbstractTool.get_tool(tool.keys[0]).new(tool.values[0])
        connection_result = tool_obj.test_connection
        connected_tools << tool_obj if !connection_result
        @errors << connection_result if connection_result
      end
      @tools = connected_tools
    end
    
  end
end