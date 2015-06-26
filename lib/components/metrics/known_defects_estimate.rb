# encoding : utf-8

require 'metrics/known_defects_base'

module MGT
  class KnownDefectsEstimate < KnownDefectsEstimateBase

    private
    
    def define_calculatation
      @pm_tool.known_defects_estimate
    end

  end
end