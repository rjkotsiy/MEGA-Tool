# encoding : UTF-8
#
require 'java'
require 'lib/3rdparty/java/jars/tfs.jar'
require 'lib/3rdparty/java/jars/json_simple.jar'
require 'lib/3rdparty/java/jars/com.microsoft.tfs.sdk-11.0.0.jar'
require 'tools/pm_tools/tfs_adapters/tfs_base'

##
# This class implements fetching data from TFS Corporate system.

module MGT
    class TFSCorporateEdition < MGT::TFSBase

      # class constructor, initializing params
      def initialize args
        super(args)
        init_client        
      end

      ##
      # method create access client for TFS local
      def init_client
        tfs_access_client_proxy = JavaUtilities.get_proxy_class('com.tfs.query.QueryTFSData')
        @tfs_access_client = tfs_access_client_proxy.new(@args.url, @args.username, @args.password)
      end

      ##
      # method check, can we get data or not with incoming parameters
      def metrics_data
        @tfs_access_client.fetchTFSMetrics(
            @args.project,
            @args.sprint_start_date,
            @args.sprint_end_date,
            @args.tags
        )
      end

      ##
      # fetch work items from TFS project and provide some errors if exists
      def tfs_do_fetch
        errors  = nil

        if @tfs_access_client
          err_code = metrics_data

          if err_code == Java::ComTfsQuery::TFS_ERROR_CODES::TFS_EXCEPTION_CONNECTION_ERROR
            error ='Invalid endpoint url, please check you url and try again'
          elsif  err_code == Java::ComTfsQuery::TFS_ERROR_CODES::TFS_EXCEPTION_ACCESS_DENIED
            errors = 'Access denied, please check your credentials'
          elsif err_code == Java::ComTfsQuery::TFS_ERROR_CODES::TFS_EXCEPTION_INVALID_QUERY
            errors = 'Invalid query, please check you iteration path or state condition'
          elsif err_code == Java::ComTfsQuery::TFS_ERROR_CODES::TFS_SUCCESS
            all_defect_debt_estimation
          end
        else
          errors = 'Error with initializing TFS client'
        end
        binding.pry
        errors
      end

      ##
      # method return all items, technical defects and debts
      def all_defect_debt_estimation
        @work_items_hash = JSON.parse(@tfs_access_client.toJSON)

        @known_defect_estimate = @tfs_access_client.getDefectEstimatesWithoutTechDebt
        @known_defect_techdebt_estimate = @tfs_access_client.getDefectEstimatesWithTechDebt
        @techdebt_backlog_size = @tfs_access_client.getBacklogSizeWithTechDebt
      end

  end
end
