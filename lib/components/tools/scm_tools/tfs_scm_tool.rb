# encoding: utf-8

require 'tools/scm_tools/scm_tool'

require 'java'
require 'lib/3rdparty/java/jars/tfs.jar'
require 'lib/3rdparty/java/jars/com.microsoft.tfs.sdk-11.0.0.jar'
require 'lib/3rdparty/java/jars/diffutils-1.2.1.jar'
require 'lib/3rdparty/java/jars/commons-io-2.4'
require 'lib/3rdparty/java/jars/json_simple.jar'


module MGT
  class TfsTool
    include MGT::ScmTool

    ##
    # fetching all information
    def initialize(args)
      super(args)
      @project = args.project || ''
      @branch = args.branch || ''
      @all_commits = []
      @all_reviewed_commits = []
      @accepted_file_extensions = string_or_array(args, :accepted_extensions, :downcase )

      @project = "#{@project}/#{@branch}" if @branch != ''
    end

    ##
    # check for connection to GitHub repository with incoming parameters
    def test_connection
      errors = nil
      begin
        init_tfs_client
      rescue 
        errors = "TFS connection error"
      end

      errors
    end


    ##
    # method return count of changes for array of revisions
    def all_changes_in_revisions change_set

      total_changes = 0
      
      change_set.each_with_index do |revision, index|
        total_changes += @tfs_access_client.getChanges(change_set[index + 1], change_set[index]) if index + 1 < change_set.size
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

      all_commits = @tfs_access_client.getRevisions(@project, date_start, date_end)
      
      all_commits.each do |commit|
        @all_commits << commit.getChangesetID()
        @all_reviewed_commits << commit.getChangesetID() if commit.getComment().include? @reviewed_by_tag
      end

      @all_commits

    end

    private

    ##
    # initialize TFS Java proxy client
    def init_tfs_client    
      tfs_access_client_proxy = JavaUtilities.get_proxy_class('com.tfs.query.QueryTFSData')
      @tfs_access_client = tfs_access_client_proxy.new(@url, @username, @password)      

      if @accepted_file_extensions.count == 0 
        @accepted_file_extensions[0] == "*.*"
      end

      @tfs_access_client.setAcceptedExtension(java.util.ArrayList.new @accepted_file_extensions)          

      ''
    end

  end

end