# encoding: utf-8

require 'spec_helper'
require 'metrics/known_defects_estimate'

RSpec.describe MGT::KnownDefectsEstimate do

  it 'inherited from AbstractMetric' do
    expect(MGT::KnownDefectsEstimate.ancestors).to include(MGT::AbstractMetric)
  end

  it 'write tests'
end