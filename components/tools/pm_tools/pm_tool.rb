# encoding: utf-8

require 'tools/abstract_tool'

module MGT
  module PmTool

    attr_accessor :project

    include MGT::AbstractTool

    def initialize(args)
      super(args)
    end
    
    def known_defects_estimate
      raise NotImplementedError.new('Implement method :known_defects_estimate')
    end

    def technical_debt_estimate
      raise NotImplementedError.new('Implement method :technical_debt_estimate')
    end

    def technical_backlog_size
      raise NotImplementedError.new('Implement method :technical_backlog_size')
    end

  end
end