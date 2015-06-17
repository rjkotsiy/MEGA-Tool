# encoding: utf-8

require 'metrics/abstract_metric'
require 'metrics/adapters/code_review_coverage_adapter.rb'

module MGT
  class CodeReviewCoverage < AbstractMetric
    attr_reader :reviewed_coverage, :all_changes_in_commits, :all_reviewed_changes, :sprint_start_date, :sprint_end_date

    def self.tool_types      
      self.tools.values        
    end

    def self.tools 
      {code_review_tool: CodeReviewTool, source_control_tool: ScmTool}
    end

    def initialize(obj)
      super(obj)
      reviewed_coverage = all_changes_in_commits = all_reviewed_changes = 0
    end

    def calculate
      define_metrics_adapter
    
      decorate_output (MGT::CodeReviewCoverageAdapters.adapter.calculate(@code_review_tool, @source_control_tool))
    end


    private

    def define_metrics_adapter

      if !@source_control_tool.reviewed_by_tag.empty?
        MGT::CodeReviewCoverageAdapters.adapter = :CodeReviewCoverageReviewedByTag
      else
        MGT::CodeReviewCoverageAdapters.adapter = :CodeReviewCoverageStandart
      end
    end

    def decorate_output metrics
      
      @reviewed_coverage = metrics[:reviewed_coverage]
      @all_changes_in_commits = metrics[:all_changes_in_commits]
      @all_reviewed_changes = metrics[:all_reviewed_changes]
      @sprint_start_date = metrics[:sprint_start_date]
      @sprint_end_date = metrics[:sprint_end_date]

      output_buffer = []
      output_buffer << ["Code Review Coverage - (#{@sprint_start_date}-#{@sprint_end_date})", 'Value', 'Changed LoC','Reviewed LoC']
      output_buffer << ['', "#{@reviewed_coverage}%", "#{@all_changes_in_commits}","#{@all_reviewed_changes}"]
      output_buffer << []
    end

  end
end