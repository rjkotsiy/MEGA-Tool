# encoding : utf-8

require 'spec_helper'
require 'tools/pm_tools/pm_tool'

RSpec.describe MGT::PmTool do

  it 'should include module AbstractTool' do
    expect(MGT::PmTool.included_modules).to include(MGT::AbstractTool)
  end

  it 'write tests'
end