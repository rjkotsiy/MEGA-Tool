# encoding: utf-8

require 'tools/scm_tools/scm_tool'
require 'octokit'

module MGT
  class GitHubTool
    include MGT::ScmTool

    ##
    # fetching all information
    def initialize(args)
      super(args)
      @repository = args.repository || ''
      @branch = args.branch || ''
      @all_commits = []
      @all_reviewed_commits = []
      @github_client = Octokit::Client
      @accepted_file_extensions = string_or_array(args, :accepted_extensions, :downcase )
      @personal_access_token = args.personal_access_token || nil
    end

    ##
    # check for connection to GitHub repository with incoming parameters
    def test_connection
      errors = nil
      begin

        if @personal_access_token
          @github_client = Octokit::Client.new(:access_token => @personal_access_token)
        else
          @github_client = Octokit::Client.new \
            :login => @username,
            :password => @password
        end

        user = @github_client.user
        user.login     

      rescue  Octokit::Forbidden
        errors = "403 - Forbidden"        
      rescue Octokit::Unauthorized
        errors = "401 - Bad credentials for GitHub repository"
      rescue Octokit::ServerError
        errors = "(500-599) - GitHub server error"
      end

      binding.pry

      errors
    end

    ##
    # method return count of changes for array of revisions
    def all_changes_in_revisions sha_array

      total_changes = 0
      first_revision = 0

      sha_array.each_with_index do |revision, index|
        total_changes += count_diffs [sha_array[index], sha_array[index + 1]] if index + 1 < sha_array.size
      end

      total_changes
    end

    ##
    # method return all changed lines for dates period where reviewed_by tag was spec.
    def all_reviewed_commits_changes      
      all_changes_in_revisions @all_reviewed_commits
    end    

    ##
    # method returns objects related to Git repository, filtered incoming array of sha hashes
    def related_reviewed_objects commits
      @all_commits.keep_if do |commit|
         commits.index(commit.to_s)
       end
    end

    ##
    # method return all commits from repository until date
    def all_commits date_start, date_end

      all_commits = @github_client.commits_between(@repository, date_start, date_end, @branch)

      all_commits.each do |commit|
        @all_commits << commit[:sha]
        @all_reviewed_commits << commit[:sha] if commit[:commit][:message].include? @reviewed_by_tag
      end
      @all_commits

    end

    private

    ##
    # method count all changed LoC for specific commit
    def count_diffs commit

      commit_diff = @github_client.compare(@repository, commit[1], commit[0])      

      diffs = 0

      if commit_diff[:files]

        commit_diff[:files].each { |file| 

          extension_accepted = @accepted_file_extensions.count == 0 || @accepted_file_extensions[0] == "*.*"

          if !extension_accepted
            file_ext = File.extname file[:filename]            
            file_ext = "*" + file_ext
            extension_accepted = @accepted_file_extensions.include? file_ext
          end

          diffs += file.changes if extension_accepted

        } 

      end

      diffs
    end    

  end

end