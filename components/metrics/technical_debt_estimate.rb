# encoding : utf-8
require 'metrics/known_defects_base'

module MGT
  class TechnicalDebtEstimate < KnownDefectsEstimateBase

    private

    def define_calculatation
      @pm_tool.technical_debt_estimate
    end

  end
end