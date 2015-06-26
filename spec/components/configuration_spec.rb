# encoding: utf-8
require 'spec_helper'
require 'pry'

RSpec.describe Analytics::Configuration do
  let (:config_class) {Analytics::Configuration}
  subject do
    Analytics::Configuration.new
  end

  it { is_expected.to be_kind_of(config_class) }
  it { is_expected.to respond_to(:enabled_elements)  }

  it 'should remove instance variable' do
    allow(config_class).to receive(:config_path) do
      File.join(Dir.pwd, 'spec', 'fixtures', 'metrics_fixture.properties')
    end
    subject.instance_eval { @component_name = 'present' }
    expect { subject.remove }.to change{ subject.instance_variable_defined?(:@component_name) }.from(true).to(false)
  end

  it 'should present correct path' do
    path = subject.config_path
    expect(path).to be_a(String)
    expect(path).to end_with('metrics.properties')
    expect(path).to include('metrics', 'properties')
  end


  it '#os' do
    expect(config_class.os).to eq(:windows).or eq(:linux).or eq(:macosx).or eq(:unix).or raise_error(/unknown os/)
  end

  context 'read fixtures file' do
    before(:each) do
      allow_any_instance_of(Analytics::Configuration).to receive(:config_path) do
        File.join(Dir.pwd, 'spec', 'fixtures', 'metrics_fixture.properties')
      end
    end

    it { is_expected.to respond_to(:git, :svn, :perforce, :jira, :rally, :sonarqube, :tfs, :reviewboard, :crucible) }
    context 'it read right value from..' do
      it 'git' do
        expect(subject.git.URL).to eq('path_to_git_repository.git')
      end

      it 'svn' do
        expect(subject.svn.URL).to match(/http/)
        expect(subject.svn.username).to start_with('your')
        expect(subject.svn.password).to end_with('password')
      end

      it 'perforce' do
        expect(subject.perforce.URL).to include('ssl')
        expect(subject.perforce.username).to end_with('in')
        expect(subject.perforce.password).to start_with('cool')
      end

      it 'jira' do
        expect(subject.jira.URL).to include('http')
        expect(subject.jira.username).to eq('administrator')
        expect(subject.jira.password).to start_with('123')
        expect(subject.jira.password).to end_with('456')
        expect(subject.jira.project).to eq('SDOA')
        expect(subject.jira.employees).to an_instance_of(Array)
        expect(subject.jira.employees).to contain_exactly('employee1', 'employee2')
        expect(subject.jira.priorities).to be_a(String)
        expect(subject.jira.priorities).to eq('medium')
        expect(subject.jira.issue_types).to be_a(Array)
        expect(subject.jira.issue_types).to eq(['bug', 'sub-bug'])
      end

      it 'rally' do
        expect(subject.rally.URL).to include('rally')
        expect(subject.rally.username).to eq('rally_login')
        expect(subject.rally.password).to start_with('rally')
        expect(subject.rally.workspace).to eq('Workspace 1')
        expect(subject.rally.project).to include('1')
        expect(subject.rally.tags).to eq('Technical Debt')
      end

      it 'sonarqube' do
        expect(subject.sonarqube.URL).to match(/localhost:9000/)
        expect(subject.sonarqube.username).to start_with('ad')
        expect(subject.sonarqube.password).to end_with('min')
      end

      it 'crucible' do
        expect(subject.crucible.URL).to include('crucible')
        expect(subject.crucible.username).to eq('cru_admin')
        expect(subject.crucible.password).to end_with('cru')
        expect(subject.crucible.project).to eq('CRSSMGT')
      end

      it 'reviewboard' do
        expect(subject.reviewboard.URL).to match(/your_location/)
        expect(subject.reviewboard.username).to eq('re_admin')
        expect(subject.reviewboard.password).to end_with('password')
      end

      it 'tfs' do
        expect(subject.tfs.URL).to include('http://local')
        expect(subject.tfs.username).to eq('tfs_login')
        expect(subject.tfs.password).to start_with('tfs')
        expect(subject.tfs.password).not_to be_empty
        expect(subject.tfs.project).to eq('DataMetrics')
        expect(subject.tfs.tags).to match(/Technical Debt/)
      end

    end

  end
end