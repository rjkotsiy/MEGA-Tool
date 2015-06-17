# encoding : UTF-8

##
# This class implements class for inheritance with basic options.
module MGT
    class TFSBase
      attr_accessor :work_items_hash,
                    :known_defect_estimate,
                    :known_defect_techdebt_estimate,
                    :techdebt_backlog_size
      ##
      # class constructor, initializing args
      def initialize args
        @args = args
        @techdebt_backlog_size = 0
        @known_defect_estimate = 0.0
        @known_defect_techdebt_estimate = 0.0          
      end
  end
end