# encoding: utf-8

require 'tools/scm_tools/scm_tool'
require 'git'
require 'win/git_lib_ext'
require 'base64'
require 'logger'

module MGT
  class GitTool
    include MGT::ScmTool

    ##
    # fetching all information
    def initialize(args)
      super(args)

      @url = args.URL
      create_temporary_folder
    end

    ##
    # check for connection to Git with incoming parameters
    def test_connection
      errors = nil
      local_path = local_location_of_repository(encode_folder_name)
      begin
        initialize_or_pull_repository(local_path, @url)
      rescue Git::GitExecuteError
        errors = 'Permission denied for Git system.'
      end      
      errors
    end

    ##
    # method return output array for visualizer
    def get_all_information
      output_data =[%w(Commiter-name Commiter-mail Message Revision-hash Timestamp File-path Modification-type File-name File-extension Insertions Deletions Max(Insertions/Deletions))]
      git_commits = fetch_all_information
      git_commits.each do |commit|

        table_line = MGT::GitLine.new(commit.author_name, commit.author_email, commit.message, commit.rev_hash.to_s, commit.timestamp.to_s).freeze
        commit.changes.each do |path, information|
          line = table_line.dup
          line.file_path = path
          line.modification_type = information.modification_type
          line.file_name = file_name(path)
          line.file_extension = file_extension(path)
          line.insertions, line.deletions, line.max_ins_del = information.to_a[1..3]

          output_data << line.to_a
        end
      end
      output_data
    end

    ##
    # method return count of changes for array of revisions
    def all_changes_in_revisions array
      array.inject(0) {|main_sum, commit|        
        main_sum += count_diffs_in_commit commit
      }
    end

    ##
    # method return all changed lines for dates period where reviewed_by tag was spec.
    def all_reviewed_commits_changes      
      diff_count = 0

      @all_for_period.each do |commit|
          diff_count += count_diffs_in_commit commit if commit.message.include? @reviewed_by_tag
      end

      return diff_count
    end    

    ##
    # method returns objects related to Git repository, filtered incoming array of sha hashes
    def related_reviewed_objects arr
      @all_for_period.keep_if do |commit|
        arr.index(commit.to_s)
      end
    end

    ##
    # method return all commits from repository until date
    def all_commits date_start, date_end
      begin_time = Time.parse(date_start).to_i.to_s
      end_time = Time.parse(date_end).to_i.to_s
      encoded_ssh = encode_folder_name
      path = local_location_of_repository(encoded_ssh)
      @all_for_period = initialize_or_pull_repository(path, @url).log(count = 100000000).since(begin_time).until(end_time).to_a
    end

    private

    ##
    # method count all changed LoC for specific commit
    def count_diffs_in_commit commit
      #TODO, rkotsiy: "if commit.parent" should be removed after https://github.com/schacon/ruby-git/pull/176 will be merged
      if commit.parent      
        commit.diff_parent.stats[:files].each_value.inject(0) { |sum, value| sum += value.values.inject(:+) }    
      else
        0
      end
    end    

    ##
    # method create temporary folder for storage copy of repository

    def create_temporary_folder
      path = File.join(Dir.home, ".analytics")
      unless Dir.exist?(path)
        Dir.mkdir(path, 0755)
      end
    end

    ##
    # method create or update local copy of Git repository
    def initialize_or_pull_repository local_path, remote_path
      if  Dir.exist?(local_path)
        git = Git.open(local_path)
        git.reset
        git.pull
      else
        puts ' .... Clonning  git repository .... '
        git = Git.clone(remote_path, local_path)
      end
      git
    end

    ##
    # method return type of modifications from current file
    def type_of_modifications commit
      obj = {}
      begin
        commit.diff_parent.entries.each do |info|
          obj.merge! "#{info.path}" => "#{info.type}"
        end unless commit.parents.empty?
      rescue ArgumentError
        git_logger('git_fetch').error "There are a lot of files in differences at #{commit} commit"
      rescue Git::GitExecuteError
        git_logger('git_fetch').error "There are 2>&1:fatal: ambiguous argument at #{commit} commit"
      end
      obj
    end

    ##
    # method return basic structure for commit
    def raw_commit_structure commit
      MGT::GitCommit.new(
          commit.author.name,
          commit.author.email,
          commit.message,
          commit,
          commit.committer_date,
          {}
      )
    end

    ##
    # method return structure for file info
    def other_file_info obj, file_path, changes
      MGT::AddDeleteGITInfo.new(
          obj[file_path],
          changes[:insertions],
          changes[:deletions],
          [changes[:insertions], changes[:deletions]].max
      )
    end

    ##
    # method return extra information about files in current commit
    def fetching_other_file_information commit, obj, raw_commit
      commit.diff_parent.stats[:files].map do |file_path, changes|
        clone_obj = raw_commit.clone
        clone_obj.changes = {file_path => other_file_info(obj, file_path, changes)}
        clone_obj
      end
    end

    def encode_folder_name
      Base64.strict_encode64 @url
    end

    ##
    # create new instance of logger, for logging some errors

    def git_logger
      file = File.open('git_logger.log', File::WRONLY | File::APPEND | File::CREAT)
      Logger.new(file)
    end

    ##
    # method return full path to local repository
    def local_location_of_repository name
      File.join(Dir.home, ".analytics", name).gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)
    end

    ##
    # deprecated method
    def fetch_all_information
      result = []
      puts '....fetching Git repository.....'
      all_commits.each do |commit|
        # this variable store key = file_path, and value = type of modifications of file, we need it for output statistic.
        obj = type_of_modifications(commit)
        #todo: some strange behavior with initial commit
        result.concat(fetching_other_file_information(commit, obj, raw_commit_structure(commit))) unless obj.empty?
      end
      result
    end

  end

  ##
  # class create basic structure for Git commit

  class GitCommit < Struct.new :author_name, :author_email, :message, :rev_hash, :timestamp, :changes
  end

  ##
  # class create basic structure for differences;
  class AddDeleteGITInfo < Struct.new :modification_type, :added_str, :deleted_str, :changedMAX
  end

  ##
  # return structure for output data
  GitLine = Struct.new :commiter, :commiter_email, :message, :rev_hash, :date, :file_path, :modification_type, :file_name, :file_extension, :insertions, :deletions, :max_ins_del

end