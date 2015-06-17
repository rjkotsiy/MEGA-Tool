# encoding: utf-8

require 'tools/scm_tools/scm_tool'

require 'java'

require 'lib/3rdparty/java/jars/svnkit-1.8.8.jar'
require 'lib/3rdparty/java/jars/svnstatistics.jar'
require 'lib/3rdparty/java/jars/sequence-library-1.0.3.jar'
require 'lib/3rdparty/java/jars/slf4j-api-1.7.12.jar'
require 'lib/3rdparty/java/jars/slf4j-simple-1.7.12.jar'
require 'lib/3rdparty/java/jars/sqljet-1.1.10.jar'

java_import java.lang.System

java_import java.util.ArrayList
java_import java.util.List

import org.tmatesoft.svn.core.SVNException;
import org.tmatesoft.svn.core.SVNLogEntry;
import org.tmatesoft.svn.core.SVNLogEntryPath;
import org.tmatesoft.svn.core.SVNURL;
import org.tmatesoft.svn.core.auth.ISVNAuthenticationManager;
import org.tmatesoft.svn.core.internal.io.dav.DAVRepositoryFactory;
import org.tmatesoft.svn.core.internal.io.fs.FSRepositoryFactory;
import org.tmatesoft.svn.core.internal.io.svn.SVNRepositoryFactoryImpl;
import org.tmatesoft.svn.core.io.SVNRepository;
import org.tmatesoft.svn.core.io.SVNRepositoryFactory;
import org.tmatesoft.svn.core.wc.SVNWCUtil;

##
# This class implements fetching SVN from Repository.
module MGT
  class SvnTool
    include MGT::ScmTool
      attr_reader :all_commits, :start_rev, :end_rev

        def initialize(args)
          super(args)
          @accepted_file_extensions = string_or_array(args, :accepted_extensions, :downcase )

          @all_commits = []
          @all_reviewed_commits = []
        end

        ##
        # check for connection to SVN with incoming parameters were specified in configuration file.
        def test_connection
          err_spool = nil
          begin
            setup_libs
            get_repository_instance
          rescue Java::OrgTmatesoftSvnCore::SVNException => svne 
            err_spool = "Error while connecting to SVN repository URL: " + @url
          end          
          init_svn_statistics_class          
          err_spool
        end

        ##
        # method return output array for visualizer
        def get_all_information
        end

        ##
        # method return array of revisions from all commits and reviewed array of revisions
        def all_commits from_date, to_date

          get_revisions_range from_date, to_date

          get_log_entries(@start_rev, @end_rev).each do |log_entry|

            @all_commits.push (log_entry.getRevision())

            log_message = log_entry.getMessage()

            @all_reviewed_commits.push (log_entry.getRevision()) if log_message.include? @reviewed_by_tag

          end
          
          @all_commits
        end

        ##
        # method return count of changed code lines for array of revisions
        def all_changes_in_revisions revisions=nil
          if revisions == nil
            return @svn_statistics.getChangesForRevisions(@start_rev, @end_rev, false)            
          end

          prev_revision =  get_prev_revision revisions[0]

          changes_count = 0 

          revisions.each do |revision|
            changes_count += @svn_statistics.getChangesForRevisions(prev_revision, revision, false)
            prev_revision = revision
          end
          changes_count
        end

        ##
        # method return all changed lines for dates period where reviewed_by tag was spec.
        def all_reviewed_commits_changes
          all_changes_in_revisions @all_reviewed_commits
        end

        ##
        # method returns revisions related to svn repository
        def related_reviewed_objects arr
          @all_commits.keep_if do |commit|
            arr.index(commit.to_s)
          end
        end


        private

        # java string array for svn sdk methods call compatibility
        @@dummy_array = [].to_java(:string)

        ##
        # method initializing authentication and return the instance of svn repository in case of success
        def get_repository_instance              
          @repository = SVNRepositoryFactory.create(SVNURL.parseURIEncoded( @url ))
          @auth_manager = SVNWCUtil.createDefaultAuthenticationManager( @username, @password )

          @repository.setAuthenticationManager(@auth_manager)
        end

        ##
        # get all log entries for specified start end revision's
        def get_log_entries look_up_rev, end_rev
          @repository.log(@@dummy_array, nil, look_up_rev, end_rev, true, true)
        end

        ##
        # method prepares Java Svn SDK all necessary setup's
        def setup_libs
          DAVRepositoryFactory.setup()
          SVNRepositoryFactoryImpl.setup()        
          FSRepositoryFactory.setup()
        end

        ##
        # method return start end revisions for desired dates
        def get_revisions_range from_date, to_date

          format = java.text.SimpleDateFormat.new("yyyy/MM/dd", java.util::Locale::ENGLISH)

          jfrom_date = format.parse(from_date)
          jto_date = format.parse(to_date)

          @start_rev = @repository.getDatedRevision(jfrom_date);
          @end_rev = @repository.getDatedRevision(jto_date);
          
        end

        ##
        # look up for previous to first revision
        def get_prev_revision commit
          look_up_rev = commit.to_i

          while look_up_rev do
            look_up_rev = look_up_rev - 1
            begin
              if @repository.log(@dummy_array, nil, look_up_rev, look_up_rev, true, true).size != 0             
                return look_up_rev
              end
            rescue Java::OrgTmatesoftSvnCore::SVNException
            end
          end
          look_up_rev = 0
        end

        ##
        # init java SVNStatistics class
        def init_svn_statistics_class
          java_class_proxy = JavaUtilities.get_proxy_class('com.svn.client.SVNStatistics')
          @svn_statistics = java_class_proxy.new(@auth_manager, @repository) || nil
          if @accepted_file_extensions.count == 0 
            @accepted_file_extensions[0] == "*.*"
          end
          @svn_statistics.setAcceptedExtension(java.util.ArrayList.new @accepted_file_extensions)          
        end

  end
end
