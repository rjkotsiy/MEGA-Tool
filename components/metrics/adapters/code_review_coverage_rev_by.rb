# encoding: utf-8

module MGT
  module CodeReviewCoverageAdapters
    module CodeReviewCoverageReviewedByTag
      extend self

      def calculate (dummy, source_control_tool)

        sprint_start_date = source_control_tool.sprint_start_date
        sprint_end_date  = source_control_tool.sprint_end_date

        all_reviewed_changes = 0
        all_changes_in_commits = 0
        reviewed_coverage = 0

        # all commits
        all_commits_hash = source_control_tool.all_commits(sprint_start_date, sprint_end_date)
        all_changes_in_commits = source_control_tool.all_changes_in_revisions(all_commits_hash)
        all_reviewed_changes = source_control_tool.all_reviewed_commits_changes
        
        # total percentage
        reviewed_coverage = ((all_reviewed_changes/all_changes_in_commits.to_f).round(3) * 100).round(3)
        
        {
         :reviewed_coverage => reviewed_coverage,
         :all_reviewed_changes => all_reviewed_changes,
         :all_changes_in_commits => all_changes_in_commits,
         :sprint_start_date => sprint_start_date,
         :sprint_end_date => sprint_end_date         
        }

      end

    end
  end
end