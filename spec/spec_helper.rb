require 'simplecov'
require 'factory_girl'
require 'load_path'
require 'simplecov-rcov'
# require 'application'

SimpleCov.start do
  add_group 'Lib', 'lib/components'
end

class SimpleCov::Formatter::MergedFormatter
  def format(result)
    SimpleCov::Formatter::HTMLFormatter.new.format(result)
    SimpleCov::Formatter::RcovFormatter.new.format(result)
  end
end
SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter

RSpec.configure do |config|
  config.color = true
  config.formatter = :documentation
  config.include FactoryGirl::Syntax::Methods
end