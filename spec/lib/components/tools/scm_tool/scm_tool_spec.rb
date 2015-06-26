require 'spec_helper'
require 'tools/scm_tools/scm_tool'

RSpec.describe MGT::ScmTool do
  it 'should include module AbstractTool' do
    expect(MGT::ScmTool.ancestors).to include(MGT::AbstractTool)
  end
  it 'write tests'
end