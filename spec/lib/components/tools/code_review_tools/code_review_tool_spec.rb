# encoding : utf-8

require 'spec_helper'
require 'tools/code_review_tools/code_review_tool'

RSpec.describe MGT::CodeReviewTool do
  it 'should include module AbstractTool' do
    expect(MGT::CodeReviewTool.included_modules).to include(MGT::AbstractTool)
  end
  it 'write tests'
end