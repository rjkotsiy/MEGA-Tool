# encoding : utf-8

require 'metrics/abstract_metric'

module MGT
  class CodeViolationsAndCodeDuplicationGrowth < AbstractMetric

    def self.tool_types      
      self.tools.values        
    end

    def self.tools 
      {quality_tool: QualityTool}
    end

    def initialize(obj)
      super(obj)
    end

    def calculate
      @quality_tool.get_statistics
    end

  end
end