# encoding: utf-8

module MGT
  class AbstractMetric
    attr_reader :configured_tools, :validated_tools

    def initialize tools
      @configured_tools = tools
      @validated_tools = 0
      define_tools
    end

    def calculate
      raise NotImplementedError.new('Implement method: calculate for your metric!')
    end

    ##
    # default method for metric tools validation, should be override in child class
    def validate_tools
      return validated_tools == self.class.tools.size
    end

    private
    
    def define_tools
      self.class.tools.each do |key, tool_parent_class|
        @configured_tools.each do |tool| 
          if tool.class < tool_parent_class
            @validated_tools += 1
            instance_variable_set("@#{key}".to_sym, tool)        
          end
        end  
      end
    end

  end
end