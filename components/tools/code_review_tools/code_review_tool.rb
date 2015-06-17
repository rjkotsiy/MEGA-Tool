# encoding: utf-8

require 'tools/abstract_tool'

module MGT
  module CodeReviewTool
    include MGT::AbstractTool

    attr_accessor :project

    def initialize(args)
      super(args)
    end

    def array_of_revisions
      raise NotImplementedError.new('Implement method: array_of_revisions() for your tool!')    	
    end

  end
end