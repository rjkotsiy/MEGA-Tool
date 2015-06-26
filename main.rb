# encoding: utf-8

LIB_PATH = File.join(Dir.pwd, 'lib')
COMPONENTS_PATH = File.join(LIB_PATH, 'components')

$LOAD_PATH.unshift(LIB_PATH) unless $LOAD_PATH.include?(LIB_PATH)
$LOAD_PATH.unshift(COMPONENTS_PATH) unless $LOAD_PATH.include?(COMPONENTS_PATH)

require 'configurator'
require 'workers'
require 'palett'
require 'presenters/csv_presenter'
require 'updater/update_notifier'

#set DEBUG to true for passing all metrics checking and hold up on some breakpoints
@@DEBUG = false

puts 'Checking for MEGA tool updates...'
MGT::UpdateNotifier.check_version()

puts 'Checking metrics configuration...'

configurator = MGT::Configurator.instance

configurator.init ("") 

metrics = configurator.create

# prints error if so
puts configurator.get_errors unless configurator.get_errors.empty?

# finish program if there are any metric
if metrics.empty?	
	puts 'No metrics for processing, please check you configuration file!'	
	exit 1 
end

##
# initialize Worker and run all available metrics
metrics_data = MGT::Workers.new(metrics).run

puts 'Done...........................'

##
# prepeare metrics report file
MGT::CsvPresenter.new.print(metrics_data.flatten(1))
