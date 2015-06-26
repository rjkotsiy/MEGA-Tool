# encoding: utf-8

require 'spec_helper'
require 'metrics/technical_debt_estimate'

RSpec.describe MGT::TechnicalDebtEstimate do

  it 'inherited from AbstractMetric' do
    expect(MGT::TechnicalDebtEstimate.ancestors).to include(MGT::AbstractMetric)
  end

  it 'write tests'
end