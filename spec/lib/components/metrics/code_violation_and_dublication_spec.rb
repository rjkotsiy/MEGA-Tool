# encoding: utf-8

require 'spec_helper'
require 'metrics/code_violation_and_dublication'

RSpec.describe MGT::CodeViolationAndDublication do

  it 'inherited from AbstractMetric' do
    expect(MGT::CodeViolationAndDublication.ancestors).to include(MGT::AbstractMetric)
  end

  it 'write tests'
end