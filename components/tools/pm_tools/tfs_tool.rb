# encoding : UTF-8
require 'tools/pm_tools/tfs_adapters/tfs-corporate-edition'
require 'tools/pm_tools/tfs_adapters/tfs-cloud-edition'

##
# This class implements fetching data from TFS system.

module MGT
  class TFSTool
    include MGT::PmTool
    	attr_reader :args

	    def initialize(args)
	    	@args = args
	    	super(args)
	    end

        ##
        # check connection to TFS server with incoming accounts. 
        def test_connection 
          errors = nil

          if @url.include? 'visualstudio'
            @client = MGT::TFSOnlineEdition.new(@args)
          else
            @client = MGT::TFSCorporateEdition.new(@args)
          end

          errors = @client.tfs_do_fetch
        end

        ##
        # this method provide Known Defects Estimate, Technical Debt Estimate, Technical Debt Backlog Size
        def known_defects_estimate
          known_defect_estimate = @client.known_defect_estimate
          [["Known Defects Estimates = #{known_defect_estimate}"]]
        end

        ##
        # method return Technical Debt Estimate
        def technical_debt_estimate
          known_defect_techdebt_estimate = @client.known_defect_techdebt_estimate
          [["Technical Debt Estimate = #{known_defect_techdebt_estimate}"]]
        end

        ##
        # method return Technial Debt Backlog Size
        def technical_backlog_size
          techdebt_backlog_size = @client.techdebt_backlog_size
          [["Technical Debt Backlog Size = #{techdebt_backlog_size}"]]
        end

        ##
        # this method convert incoming TFS data structure to array, depend on incoming issues.

        def get_all_information
          result = [['ID', 'Title', 'Type', 'Assigned To', 'State', 'Estimation', 'Tags']]

          @work_items_hash = @client.work_items_hash

          fetching.each do |issue|
             result.push(issue.to_a)
          end
          result
        end

        private

        ##
        # get all data from TFS - workitems

        def fetching

            puts '.........Fetching TFS data .........'

            work = @work_items_hash['workitems']
            work.map do |issue|
               Analytics::ProjectManagement::TFSStructure.new(
                   *argument_decorator(issue)
              )
            end                  

        end

        ##
        # method return data in array format
        def argument_decorator (issue)
            [
              issue['id'].to_s, issue['title'], issue['type'], issue['assigned_to'], issue['state'], issue['estimate'], issue['tags']
            ]
        end

 	end # class       
    #
    # internal TFS data structure for output
    class TFSStructure < Struct.new  :id, :title, :type, :assigned_to, :state, :estimate, :effort, :tags
    end

end # module


