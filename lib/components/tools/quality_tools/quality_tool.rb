# encoding: utf-8
require 'tools/abstract_tool'

module MGT
  module QualityTool
    include MGT::AbstractTool

    attr_accessor :project

    def initialize(args)
      super(args)
    end

    def get_statistics
      raise NotImplementedError.new('Define method :get_all_information in your quality tool.')
    end

  end
end