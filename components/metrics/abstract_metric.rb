# encoding: utf-8

module MGT
  class AbstractMetric
    attr_reader :configured_tools

    def initialize tools
      @configured_tools = tools
      define_tools
    end

    def calculate
      raise NotImplementedError.new('Implement method: calculate for your metric!')
    end

    def self.validate_tools tools_set

      return true #TODO, rkotsiy: needs refactoring

      used_tool = []

      tools_set.each do |tool|      

        self.tool_types.each do |v|    
          binding.pry      
          used_tool << tool if tool < v
        end
      
      end
      return used_tool.size == self.tool_types.size

    end

    private
    
    def define_tools
      self.class.tools.each do |key, tool_parent_class|
        @configured_tools.each do |tool| 
          instance_variable_set("@#{key}".to_sym, tool) if tool.class < tool_parent_class       
        end  
      end
    end

  end
end