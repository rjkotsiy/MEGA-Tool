# encoding: utf-8

module MGT
  
    module CodeReviewCoverageReviewedPeerToPeer 
        extend self

      attr_reader :all_reviewed_changes, :all_changes_in_commits, :sprint_start_date, :sprint_end_date

      def calculate dummy, source_control_tool

        @sprint_start_date = source_control_tool.sprint_start_date
        @sprint_end_date  = source_control_tool.sprint_end_date

        all_reviewed_changes = 0
        all_changes_in_commits = 0

        # all commits
        all_commits_hash = source_control_tool.all_commits(sprint_start_date, sprint_end_date)
        
        @all_changes_in_commits = source_control_tool.all_changes_in_revisions(all_commits_hash)
        @all_reviewed_changes = source_control_tool.all_reviewed_commits_changes
        
      end

    end  
end