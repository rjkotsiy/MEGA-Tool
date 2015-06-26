# encoding: utf-8

require 'metrics/abstract_metric'

require 'metrics/review_coverage_methods/code_review_method_factory.rb'


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
      code_review_method = MGT::CodeReviewMethodFactory.new(@code_review_tool, @source_control_tool)
      code_review_method.create

      metrics = code_review_method.calculate
      decorate_output metrics
    end

    ## override
    #  validate, do we having deal with peer-to-peer metric or standart code review 
    def validate_tools 
      return false if !@source_control_tool || (!@source_control_tool && !@code_review_tool)
      return false if @source_control_tool && @code_review_tool && !@source_control_tool.reviewed_by_tag.empty?
      return false if @source_control_tool && !@code_review_tool && @source_control_tool.reviewed_by_tag.empty?
      return true  if @source_control_tool && !@code_review_tool && !@source_control_tool.reviewed_by_tag.empty? 
      true
    end

    private

    def decorate_output metric
      
      @reviewed_coverage = metric[:review_coverage]
      @all_changes_in_commits = metric[:all_changes_in_commits]
      @all_reviewed_changes = metric[:all_reviewed_changes]
      @sprint_start_date = metric[:sprint_start_date]
      @sprint_end_date = metric[:sprint_end_date]

      output_buffer = []
      output_buffer << ["Code Review Coverage - (#{@sprint_start_date}-#{@sprint_end_date})", 'Value', 'Changed LoC','Reviewed LoC']
      output_buffer << ['', "#{@reviewed_coverage}%", "#{@all_changes_in_commits}","#{@all_reviewed_changes}"]
      output_buffer << []
    end

  end
end