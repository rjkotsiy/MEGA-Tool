# encoding: utf-8
require 'load_path'
require 'conf/sonar_configs'

RSpec.describe Analytics::SONARQUBEConfigs do
  Struct.new('ForSonar', :username, :password, :URL, :project)

  subject do
     Analytics::SONARQUBEConfigs.new(Struct::ForSonar.new('admin', 'my_pass', 'http://loclahost:9000', 'Display'))
  end

  describe 'basic things' do
    it { is_expected.to be_an(Analytics::SONARQUBEConfigs) }
    it { is_expected.to respond_to(:sonar_user, :sonar_pass, :sonar_project, :sonar_ip) }
    it { is_expected.not_to  respond_to(:else_method) }
  end

  describe 'testing with configuration parameters' do
    it 'have current UserName param' do
      expect(subject.sonar_user).to eq('admin')
    end

    it 'have current Password access' do
      expect(subject.sonar_pass).to match(/pass/)
    end

    it 'have specified adress ' do
      expect(subject.sonar_ip).to start_with 'http'
    end

    it 'have project with name Display' do
      expect(subject.sonar_project).to eq 'Display'
    end

  end

end