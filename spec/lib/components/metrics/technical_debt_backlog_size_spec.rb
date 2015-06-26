# encoding: utf-8

require 'spec_helper'
require 'metrics/technical_debt_backlog_size'

RSpec.describe MGT::TechnicalDebtBacklogSize do

  it 'inherited from AbstractMetric' do
    expect(MGT::TechnicalDebtBacklogSize.ancestors).to include(MGT::AbstractMetric)
  end

  it 'write tests'
end