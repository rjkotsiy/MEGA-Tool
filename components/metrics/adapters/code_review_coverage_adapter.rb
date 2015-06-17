require "metrics/adapters/code_review_coverage_standart.rb"
require "metrics/adapters/code_review_coverage_rev_by.rb"


module MGT
  module CodeReviewCoverageAdapters
    extend self  
    
    def adapter  
      return @adapter if @adapter  
      self.adapter = :CodeReviewCoverageStandart
      @adapter  
    end  
       
    def adapter=(adapter_name)  
      case adapter_name  
      when Symbol, String  
        @adapter = MGT::CodeReviewCoverageAdapters.const_get("#{adapter_name.to_s}")  
      else  
        raise "Missing adapter name #{adapter_name}"  
      end  
    end  
    
    def calculate(code_review_tool, source_control_tool)
      adapter.calculate(code_review_tool, source_control_tool)
    end  
  end
end  