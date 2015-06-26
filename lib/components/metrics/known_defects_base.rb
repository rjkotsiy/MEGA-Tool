# encoding : utf-8

require 'metrics/abstract_metric'

module MGT
  class KnownDefectsEstimateBase < AbstractMetric
    
    def self.tool_types      
      self.tools.values        
    end

    def self.tools 
      {pm_tool: PmTool} 
    end

    def calculate 
      return define_calculatation 
    end 

    private

    def define_calculatation 
      raise NotImplementedError.new('Implement method: define_calculatation for your metric!')
    end 
       
  end
end