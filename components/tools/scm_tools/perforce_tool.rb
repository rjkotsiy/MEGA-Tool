require 'java'
require 'lib/3rdparty/java/jars/p4java.jar'

java_import java.lang.System

java_import java.io.BufferedReader;
java_import java.io.InputStream;
java_import java.io.InputStreamReader;
java_import java.util.ArrayList;
java_import java.util.List;


java_import com.perforce.p4java.core.file.DiffType
java_import com.perforce.p4java.server.IServer
java_import com.perforce.p4java.option.UsageOptions
java_import com.perforce.p4java.server.ServerFactory
java_import com.perforce.p4java.core.IChangelist
java_import com.perforce.p4java.core.IChangelistSummary
java_import com.perforce.p4java.option.server.GetChangelistsOptions
java_import com.perforce.p4java.core.IChangelistSummary
java_import com.perforce.p4java.exception.P4JavaException
java_import com.perforce.p4java.option.server.TrustOptions
java_import com.perforce.p4java.core.file.FileSpecBuilder

module MGT
  class PerforceTool
    include MGT::ScmTool

        def initialize(args)
          super(args)

          @accepted_file_extensions = string_or_array(args, :accepted_extensions, :downcase )

          @all_commits = []
          @all_reviewed_commits = []          
        end

        ##
        # check connections with incoming parameters
        def test_connection
          error = nil          
          begin
            p4_connect_to_server  
          rescue Java::ComPerforceP4javaException::ConnectionException
              error = 'Please, check your ssh path to Perforce server. '
          rescue Java::ComPerforceP4javaException::AccessException
              error = 'Please, check your credentials for Perforce. '
          end
          error
        end


        ##
        # return array of o4 revisions for dates range
        def all_commits start_date_str, end_date_str

          file_spec = FileSpecBuilder.makeFileSpecList(@branch)

          change_list = @p4server.getChangelists(1000000, file_spec, nil, nil, true, true, true, false);
          
          start_date = Date.parse(start_date_str)
          end_date = Date.parse(end_date_str)

          change_list.each do |item|

            changelist_date = Date.parse(item.getDate.to_s)

            if changelist_date >= start_date && changelist_date <= end_date
              @all_commits << item.getId
              @all_reviewed_commits << item.getId if item.getDescription.to_s.include? @reviewed_by_tag
            end
          end

          @all_commits
        end


        ##
        # method return count of changed code lines for array of revisions
        def all_changes_in_revisions revisions
      
          changes_count = 0

          revisions.each do |revision|
            changes_count += get_changes_count revision
          end

          changes_count
        end

        ##
        # method return count of reviwed by tag changed code lines
        def all_reviewed_commits_changes       
          all_changes_in_revisions @all_reviewed_commits
        end


        ##
        # method returns revisions related to perforce repository
        def related_reviewed_objects arr
          @all_commits.keep_if do |commit|
            arr.index(commit.to_s)
          end
        end


        private

        ##
        # return p4 server instance
        def p4_connect_to_server          

          p4serverUri = System.getProperty(
                      "com.perforce.p4java.serverUri",
                      "p4java" + @url)

          @p4server = ServerFactory.getServer(p4serverUri, nil)
          
          @p4server.connect 
          @p4server.setUserName(@username)
          @p4server.login(@password)           
          

          ''
        end

        ##
        # return count of changed lines for diff hunk
        def get_changed_lines_count diff_line_marker
          lines_changes = []
          diff_line_marker.each_line(32.chr) {|l| lines_changes << l}              
          lines_changes[lines_changes.size-1].to_i
        end 


        ##
        # check if file extension for current changed file is allowed
        def allow_file_extension diff_line

          return true if @accepted_file_extensions.count == 0 || @accepted_file_extensions[0] == "*.*"

          raw_ext = File.extname diff_line
          file_ext = raw_ext.split "#"
          return false unless file_ext[0] 

          corrected_ext = "*" + file_ext[0]
          @accepted_file_extensions.include? corrected_ext
        end


        ## 
        # determine start of diff block
        def start_diff_block diff_line

          diff_block_started = diff_line.start_with? "===="

          file_extension_allowed = allow_file_extension diff_line          
          
          file_extension_allowed && diff_block_started
        end

        ##
        # determine end of diff block
        def end_diff_block diff_line
          diff_line.start_with? 9.chr
        end

        ##
        # return count of summary changes for perforce revision
        def get_changes_count revision_num
          diffs = @p4server.getChangelistDiffs(revision_num, DiffType::RCS_DIFF)
          buff_reader = BufferedReader.new(InputStreamReader.new(diffs))      

          count = 0
          
          diff_hunk = buff_reader.readLine

          while diff_hunk

            if start_diff_block (diff_hunk)

              sub_diff_hunk = buff_reader.readLine                

              while sub_diff_hunk || end_diff_block(diff_hunk)
                if (sub_diff_hunk.match("[ad][0-9]+ [0-9]+"))
                  count += get_changed_lines_count(sub_diff_hunk)
                end            

                sub_diff_hunk = buff_reader.readLine                

              end

            end

            diff_hunk = buff_reader.readLine

          end
          count
        end
        
  end
end