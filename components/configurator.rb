# encoding: utf-8

require 'params_parser'
require 'metric_factory'
require 'singleton'

module MGT
  class Configurator
    include Singleton

    ##
    # parse config file and return cunfigured metrics hash
    def init filename    
      @metrics = MGT::MetricFactory.new(MGT::ParamsParser.new(filename).parse)
    end

    ##
    # method create metrics
    def create
      @metrics.create
    end

    ##
    # return errors
    def get_errors     
      @metrics.errors      
    end

  end
end