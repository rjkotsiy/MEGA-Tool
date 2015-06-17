# encoding: utf-8

require 'tool_factory'
require 'pry'

module MGT

  ##
  # class responsible for metrics
  class MetricFactory

    attr_reader :metrics, :errors

    def initialize metrics_config
      @metrics_config = metrics_config
      @errors = []
      @metrics = []
    end

    def create

      @metrics_config.each do |metric_hash|

        metric_name = metric_hash.keys[0].to_s
        metric_class = get_metric(metric_name)
        tools_config = metric_hash.values[0].flatten

        tools_classes = get_tools_classes(tools_config)
        
        validation_result = metric_class.validate_tools(tools_classes)

        if !validation_result
            @errors << "#{metric_name.scan(/[A-Z][a-z]+/).join(' ')} - invalid tools specification "
            next
        end

        tools_obj = MGT::ToolFactory.new(tools_config)

        tools_obj.create      

        @errors << tools_obj.errors if tools_obj.errors.any?

        @metrics << metric_class.new(tools_obj.tools) if tools_obj.errors.empty?

      end
      @metrics
    end

    private

    ##
    # return tools classes for given metric 
    def get_tools_classes tools_config
      tools_config.map do |tool_name| 
        MGT::AbstractTool.get_tool(tool_name.keys[0].to_s)
      end
    end

    ##
    # return appropriate class for given metric name
    def get_metric(metric_name)
      MGT.const_get(metric_name)
    end

  end
end