# encoding: utf-8

require 'tool_factory'
require 'pry'

module MGT

  ##
  # class responsible for metrics creation and validation
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

        next if !metric_class          

        tools_config = metric_hash.values[0].flatten  
        tools = create_tools(tools_config)
  
        metric = create_metric(metric_class, tools)
        validation_result = metric.validate_tools

        @metrics << metric if validation_result && !tools.errors.any?

        decorate_errors(metric_name, tools, validation_result)        

      end
      @metrics
    end

    private

    ##
    # decorate errors 
    def decorate_errors metric_name, tools, validation_result
      human_readeble_name = metric_name.scan(/[A-Z][a-z]+/).join(' ')

      if tools.errors.any?
        @errors << "#{human_readeble_name} - metric failed: " << tools.errors
        return
      end
      
      @errors << "#{human_readeble_name} - invalid tools specification " if !validation_result

    end

    ##
    # create tools object
    def create_tools tools_config
      tools_obj = MGT::ToolFactory.new(tools_config)
      tools_obj.create
      tools_obj
    end

    ##
    # create metric object based on tools
    def create_metric metric_class, tools_object
      metric_obj = metric_class.new(tools_object.tools)
    end

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
      begin
        MGT.const_get(metric_name)
      rescue 
        @errors << "Specified metric name [#{metric_name}] is not valid!"
        nil
      end
    end

  end
end