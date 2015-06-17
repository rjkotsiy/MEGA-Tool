# encoding: utf-8
require 'tools/abstract_tool'

module MGT
  module ScmTool
    include MGT::AbstractTool

    def initialize(args)
      super(args)
    end

    def get_all_information
      raise NotImplementedError.new('Define method :get_all_information in your quality tool.')
    end

    ##
    # method return all commits from repository during period
    def all_commits date_start, date_end
      raise NotImplementedError.new('Define method :all_commits on your source control.')
    end

    ##
    # method returns objects related to repository, filtered incoming array of sha hashes
    def related_reviewed_objects arr
      raise NotImplementedError.new('Define method :related_reviewed_objects on your source control.')
    end

    ##
    # method return count of changes for array of revisions
    def all_changes_in_revisions array
      raise NotImplementedError.new('Define method :all_changes_in_revisions on your source control.')
    end
  end
end