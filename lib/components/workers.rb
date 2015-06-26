# encoding : utf-8

require 'parallel'

Dir['lib/components/metrics/*.rb'].reject{|item| item == 'lib/components/metrics/abstract_metric.rb'}.each { |responsible_class| require responsible_class }

module MGT
  class Workers
    attr_reader :metrics

    ##
    # method initialize all workers threads
    def initialize metrics
      @metrics = metrics
    end

    ##
    # run each process of calculation in separate thread
    def run
      Parallel.map(metrics, :in_threads => metrics.size, :progress => "Fetching metrics.................") do |process|
        process.calculate
      end
    end
  end
end