# encoding: utf-8

require 'metrics/review_coverage_methods/code_review_coverage_standart.rb'
require 'metrics/review_coverage_methods/code_review_coverage_peer_to_peer.rb'

module MGT

    class CodeReviewMethodFactory

      attr_reader :code_review_tool, :source_control_tool, :code_review_method

      def initialize code_review_tool, source_control_tool
        @code_review_tool = code_review_tool
        @source_control_tool = source_control_tool
      end

      def create

        @code_review_method = MGT::CodeReviewCoverageStandart     

        if !@source_control_tool.reviewed_by_tag.empty?
            @code_review_method  = MGT::CodeReviewCoverageReviewedPeerToPeer
        end        
      end

      def calculate

        @code_review_method.calculate @code_review_tool, @source_control_tool

        all_reviewed_changes = @code_review_method.all_reviewed_changes
        all_changes_in_commits = @code_review_method.all_changes_in_commits

        review_coverage = ((all_reviewed_changes/all_changes_in_commits.to_f).round(3) * 100).round(3) 
        
        {
         :review_coverage => review_coverage,
         :all_reviewed_changes => all_reviewed_changes,
         :all_changes_in_commits => all_changes_in_commits,
         :sprint_start_date => @code_review_method.sprint_start_date,
         :sprint_end_date => @code_review_method.sprint_end_date         
        }

      end

    end  
end