# encoding: utf-8
require 'ostruct'

module MGT
  ##
  # class responsible for parse incoming file with configs
  class ParamsParser

    def initialize filename
      @filename = filename
      @filename = File.join(Dir.pwd, 'config', 'metrics.properties') if filename == ""
    end

    def parse
      @enabled_elements = []
      @tools = []
      @parameters = []
      File.open(@filename, 'r') do |f|
        f.each_line do |line|


          next if (line.match /^[\s]*$\n/)

          if line.start_with?('[')
            @parameters << { @metric_name => @tools } if @metric_name && !@tools.empty?
            @metric_name = line.strip[1..-2].delete(' ').to_sym
            @tools = []

          elsif line.start_with? '@'
            @component_name = line.chomp.tr('@', '')
            sym = @component_name.intern
            @enabled_elements << @component_name
            self.class.class_eval { attr_accessor sym }
            @tools << { sym => self.send("#{@component_name}=".to_sym, OpenStruct.new()) }

          else
            arr = line.split(' : ')
            key = arr[0].strip
            value = arr[1].include?(',') ? arr[1].split(/,/).map{|el| el.strip} : arr[1].strip
            self.method("#{@component_name}".to_sym).call.send("#{key}=".intern, value)
          end

          if f.eof?
            @parameters << { @metric_name => @tools }
          end

        end
      end
      remove
      is_a_few_metric_for_one_tool
    end


    private

    ##
    # method identify your Operation System
    def self.os
      host_os = RbConfig::CONFIG['host_os']
      case host_os
        when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
          :windows
        when /darwin|mac os/
          :macosx
        when /linux/
          :linux
        when /solaris|bsd/
          :unix
        else
          raise "unknown os: #{host_os.inspect}"
      end
    end


    def is_a_few_metric_for_one_tool
      @parameters.flat_map { |item|
        if item.keys[0].to_s.include?(',')
          value = item.values[0]
          item.keys[0].to_s.split(',').map{ |key| {key.intern => value} }
        else
          item
        end
      }
    end

    def remove
      (@enabled_elements.uniq + %w(component_name filename metric_name tools enabled_elements) ).each do |instance_var|
        remove_instance_variable("@#{instance_var}".to_sym)
      end
    end

  end
end