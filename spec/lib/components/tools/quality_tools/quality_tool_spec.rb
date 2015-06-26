# encoding : utf-8

require 'spec_helper'
require 'tools/quality_tools/quality_tool'

RSpec.describe MGT::QualityTool do

  it 'should include module AbstractTool' do
    expect(MGT::QualityTool.ancestors).to include(MGT::AbstractTool)
  end

  it 'write tests'
end