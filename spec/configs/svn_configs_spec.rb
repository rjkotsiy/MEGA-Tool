# encoding: utf-8
require 'load_path'
require 'conf/svn_configs'
require 'fixtures/factories'

RSpec.describe Analytics::SVNConfigs do
  subject do
    Analytics::SVNConfigs.new(FactoryGirl.create(:svn_inc_params))
  end

  describe 'svn config should have basic parameters' do
    it { is_expected.to be_an(Analytics::SVNConfigs) }
    it { is_expected.to respond_to(:url, :username, :password) }


    it 'should have specified URL adress ' do
      expect(subject.url).to match(/http/)
    end

  end

end