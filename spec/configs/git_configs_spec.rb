# encoding: utf-8
require 'load_path'
require 'conf/git_configs'


RSpec.describe Analytics::GITConfigs do
  describe 'basic things' do

    before(:each) do
      @obj = {}
      allow(@obj).to receive(:URL) { 'http://@192.168.011.011/magnetto.git' }
    end

    subject do
      Analytics::GITConfigs.new(@obj)
    end

    it { is_expected.to be_an(Analytics::GITConfigs) }
    it { is_expected.to respond_to(:url) }
    it { is_expected.not_to respond_to(:else_method) }

    it 'should have specified URL adress ' do
      expect(subject.url).to match(/http/)
      expect(subject.url).to be_a(String)
      expect(subject.url).to end_with '.git'
    end

  end

  describe 'testing with wrong incoming parameters' do

    before(:each) do
      @obj_wrong = {}
      allow(@obj_wrong).to receive(:URL).and_return(false)
    end

    subject { Analytics::GITConfigs.new(@obj_wrong).url }

    it {is_expected.to be_a_kind_of(NilClass)}
  end

end