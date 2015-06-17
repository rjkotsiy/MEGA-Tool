# encoding: utf-8
require 'open3'
require 'date'
require 'csv'

require 'tools/code_review_tools/code_review_tool'

module MGT

    class CollaboratorCommandLineHelper
      ##
      # class constructor
      def initialize url, user, password, command_line_tool_path
        @config = {}

        @config[:url] = url
        @config[:user] = user
        @config[:password] = password
        @config[:path] = command_line_tool_path

        get_commandline_tool
        setup_credentials
      end


      ##
      # return hash of reviews {:creation_date, :phase, :changed_lines}
      def get_reviews 
        reviews = []
        CSV.parse(get_reviews_raw_csv).each_with_index do |row, index|

          if index == 0 
            next
          end

          items = Hash.new

          items[:creation_date] = row[1]
          items[:phase] = row[2]
          items[:changed_lines] = row[4]

          reviews << items
        end
        reviews
      end


      private

      ##
      # сode сollaborator tool commands
      @@login_command      = "login"
      @@admin_wget_command = "admin wget \"go?reportTitle=Reviews+Currently+In+Progress&phaseVis=y&numDefectsVis=y&reviewIdVis=y&&data-format=csv&groupDepth=0&phaseFilter=inprogress&page=ReportReviewList&component=ErrorsAndMessages&sort1=col%3D%7C%7C%7Corder%3Dasc&sort0=col%3DreviewId%7C%7C%7Corder%3Ddesc&formSubmittedreportConfig=1&reviewCreationDateVis=y&ErrorsAndMessages_fingerPrint=861101&locChangedVis=y\""

      ##
      # get collaborator command line tool executable command for specific OS
      def get_commandline_tool
        host_os = RbConfig::CONFIG['host_os']
        case host_os
          when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
            @command_line_tool = "ccollab.exe"
          when /linux/
            @command_line_tool = "ccollab"            
          when /darwin|mac os/
            @command_line_tool = "ccollab"
        end
      end

      ##
      # setup credential for current current provided user
      def setup_credentials

        cmd = @config[:path] + @command_line_tool + " " + @@login_command

        Open3.popen3( cmd ) { |input, output, error|
          input.puts @config[:url]
          input.puts @config[:user]
          input.puts @config[:password]
          input.close
                  } 

      end

      ##
      # return csv formatted string
      def get_reviews_raw_csv
        cmd = @config[:path] + @command_line_tool + " " + @@admin_wget_command
        result = ""
        error = ""

        Open3.popen3( cmd ) { |dummy_input, output, error|
          result = output.read 
          error =  error.read 
        } 

        result if error.length == 0
      end
    end


    ##
    # This class represent fetching data from Code Collaborator review tool
    class CodeCollaboratorTool      
      include MGT::CodeReviewTool

        def initialize args
          super(args)
          @tool_name = 'Code Collaborator'
        end

        ##
        # method check connection with incoming parameters
        def test_connection
          if !File.file?(@report_file)
            return "Can't find path to report file: #{@report_file}"
          end
          nil
        end


        ##
        # method return array of closed revisions, their hashes/numbers
        def array_of_revisions
        
          start_date = Date.parse(@sprint_start_date)
          end_date = Date.parse(@sprint_end_date)

          completed_reviews_ids = []

          get_reviews.each do |item|
            creation_date = Date.parse(item[:creation_date]) rescue nil
            if (item[:phase] == "Completed") && (creation_date && (creation_date >= start_date && creation_date <= end_date)) 
              completed_reviews_ids << item[:revision]
            end 
          end
          completed_reviews_ids
        end   


        private 

        ##
        # return hash of reviews {:creation_date, :phase, :changed_lines}
        def get_reviews 
          reviews = []
          CSV.foreach(@report_file, {return_headers: false}) do |item|
            items = Hash.new

            items[:revision] = item[0]
            items[:phase] = item[3]
            items[:creation_date] = item[5]

            reviews << items
          end
          reviews
        end


    end

end