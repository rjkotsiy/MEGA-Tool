# encoding : utf-8

require 'spec_helper'
require 'tools/scm_tools/git_tool'

RSpec.describe MGT::GitTool do

  it 'should include module ScmTool' do
    expect(MGT::GitTool.ancestors).to include(MGT::ScmTool)
  end

  it 'should include module AbstractTool' do
    expect(MGT::GitTool.ancestors).to include(MGT::AbstractTool)
  end

  it 'write tests'
end