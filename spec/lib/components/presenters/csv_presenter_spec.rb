# encoding : utf-8

require 'spec_helper'
require 'presenters/csv_presenter'

describe MGT::CsvPresenter do
  it 'inherited from AbstractPresenter class' do
    expect(MGT::CsvPresenter.ancestors).to include(MGT::AbstractPresenter)
  end

  it 'write more tests'
end