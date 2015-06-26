# encoding : utf-8

require 'spec_helper'
require 'tools/pm_tools/jira_tool'

RSpec.describe MGT::JiraTool do

  # subject{ MGT::JiraTool.new() }


  it 'should include module PmTool' do
    expect(MGT::JiraTool.included_modules).to include(MGT::PmTool)
  end

  it 'should include module AbstractTool' do
    expect(MGT::JiraTool.included_modules).to include(MGT::AbstractTool)
  end


  it 'write tests'
end