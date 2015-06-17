# encoding: utf-8

module MGT
  module CodeReviewCoverageAdapters
    module CodeReviewCoverageCodeCollaborator
      extend self

      def calculate (code_review_tool, source_control_tool)

        all_reviewed_changes = 0
        all_changes_in_commits = 0

        sprint_start_date = code_review_tool.sprint_start_date
        sprint_end_date  = code_review_tool.sprint_end_date

        # all commits
        all_commits_hashes = source_control_tool.all_commits(sprint_start_date, sprint_end_date)

        # number of all deletions and insertions from source control
        all_changes_in_commits = source_control_tool.all_changes_in_revisions(all_commits_hashes)

        all_reviewed_changes = code_review_tool.get_reviewed_lines
      
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