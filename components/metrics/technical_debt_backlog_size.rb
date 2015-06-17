# encoding : utf-8
require 'metrics/known_defects_base'

module MGT
  class TechnicalDebtBacklogSize < KnownDefectsEstimateBase

    private

    def define_calculatation
      @pm_tool.technical_backlog_size
    end

  end
end