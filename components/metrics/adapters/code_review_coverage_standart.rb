# encoding: utf-8


module MGT
  module CodeReviewCoverageAdapters
    module CodeReviewCoverageStandart
      extend self

      def calculate (code_review_tool, source_control_tool)

        sprint_start_date = code_review_tool.sprint_start_date
        sprint_end_date  = code_review_tool.sprint_end_date
        all_reviewed_changes = 0
        all_changes_in_commits = 0

        # all commits
        all_commits_hashes = source_control_tool.all_commits(sprint_start_date, sprint_end_date)
        
        # number of all deletions and insertions from source control
        all_changes_in_commits = source_control_tool.all_changes_in_revisions(all_commits_hashes)

        all_reviewed_changes = 0

        all_reviewed_revisions = code_review_tool.array_of_revisions || []

        # related log objects for reviewed commits
        all_related_object_reviewed_hashes = source_control_tool.related_reviewed_objects(all_reviewed_revisions)
        # count of changes in reviewed revisions
        all_reviewed_changes = source_control_tool.all_changes_in_revisions(all_related_object_reviewed_hashes)

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