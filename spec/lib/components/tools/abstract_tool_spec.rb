# encoding : utf-8

require 'spec_helper'
require 'tools/abstract_tool'
require 'fixtures/factories'

RSpec.describe MGT::AbstractTool do
  let(:dummy_class) { Class.new { include MGT::AbstractTool } }
  subject{ dummy_class.new(FactoryGirl.build(:testing_configs)) }

  it '#test_connection should raise  error' do
    expect{ subject.test_connection }.to raise_error(NotImplementedError)
  end

  it 'should set instance variables' do
    expect(subject.instance_variable_get('@tool_name')).to eq('Unknown tool')
    expect(subject.instance_variable_get('@username')).to eq('user_name')
    expect(subject.instance_variable_get('@password')).to eq('222222')
    expect(subject.instance_variable_get('@sprint_start_date')).to eq('')
    expect(subject.instance_variable_get('@sprint_end_date')).to eq('')
  end


  it '#string_or_array - convert string to array' do
    test = FactoryGirl.build(:jira_inc_params)
    expect(subject.string_or_array(test, :employees, :downcase)).to an_instance_of(Array)
    expect{ subject.string_or_array(test, :statuses) }.to change{ test.statuses }
  end
end