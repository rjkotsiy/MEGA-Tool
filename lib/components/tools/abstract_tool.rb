# encoding: utf-8

module MGT
  module AbstractTool

    attr_accessor :username, :password, :url, :sprint_start_date, :sprint_end_date, :tool_name, :reviewed_by_tag, :branch, :accepted_extensions

    def initialize obj
      @username = obj.username || ''
      @password = obj.password || ''
      @url = obj.URL || ''

      @sprint_start_date = obj.sprint_start_date || "1970/01/01"
      @sprint_end_date = obj.sprint_end_date || "2020/01/01"

      @project = obj.project || ''

      @reviewed_by_tag = obj.reviewed_by_tag || ''

      @branch = obj.branch || ''
      @accepted_extensions = obj.accepted_extensions || ''
      
      @command_line_tool_path = obj.command_line_tool_path || ''
      @report_file = obj.report_file || ''

      @tool_name = 'Unknown tool'
    end

    def test_connection
      raise NotImplementedError.new('Implement method :test_connection')
    end

    def self.get_tool tool_name
      begin
        MGT.const_get(tool_name.to_s + 'Tool')
      rescue
        nil
      end
    end

    protected

    def string_or_array(params, value, action = :capitalize)
      current_property = params.send(value)
      if params.respond_to? (value)
        if current_property.kind_of?(String)
          current_property.split(//, 1)
        else
          current_property.map(&action)
        end
      else
        []
      end
    end

  end
end