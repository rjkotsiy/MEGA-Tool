# encoding: utf-8

require 'spec_helper'
require 'metrics/code_review_coverage'

RSpec.describe MGT::CodeReviewCoverage do

  it 'inherited from AbstractMetric' do
    expect(MGT::CodeReviewCoverage.ancestors).to include(MGT::AbstractMetric)
  end

  it 'write tests'
end