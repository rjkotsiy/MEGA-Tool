# encoding: utf-8

require 'spec_helper'
require 'presenters/abstract_presenter'

RSpec.describe MGT::AbstractPresenter do
  subject { MGT::AbstractPresenter.new }

  it 'should raise error on print method' do
    expect{ subject.print('data') }.to raise_error('Called abstract method :print')
  end

  it 'should set name to instance variable' do
    expect(subject.instance_variable_get('@name')).to eq('metrics')
  end
end