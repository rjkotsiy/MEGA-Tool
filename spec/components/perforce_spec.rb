# encoding: utf-8
require 'spec_helper.rb'
require 'components/scm/adapters/perforce_fetch'
require 'fixtures/factories'

RSpec.describe Analytics::Scm::Adapters::PerforceFetching do

  let(:perforce_class) { Analytics::Scm::Adapters::PerforceFetching }
  subject {perforce_class.new}

#  it { is_expected.to respond_to(:params) }

  context '#try' do
    subject{perforce_class.try( FactoryGirl.build(:perforce_configs) )}

    it 'should return empty array with valid credentials' do
      allow(perforce_class).to receive(:p4_connect_to_server).and_return('Client was created!!')

      expect(subject).to be_a_kind_of(Array)
      expect(subject).to be_empty
    end

    describe 'should return array contained error message' do
      subject{perforce_class.try( FactoryGirl.build(:perforce_configs) )}

      it 'bad ssh_path message' do
        allow(perforce_class).to receive(:p4_connect_to_server) do
          raise Java::ComPerforceP4javaException::ConnectionException.new
        end
        expect(subject).to be_a_kind_of(Array)
        expect(subject.first).to be_eql('Please, check your ssh path to Perforce server. ')
        expect(subject.first).to match(/Please, che/)
      end

      it 'bad credential message' do
        allow(perforce_class).to receive(:p4_connect_to_server).and_raise(Java::ComPerforceP4javaException::AccessException.new())
        expect(subject).to be_a_kind_of(Array)
        expect(subject).to contain_exactly('Please, check your credentials for Perforce. ')
      end
    end
  end

  context '#all_commits' do
    subject{ perforce_class.all_commits "01/01/01", "01/01/01"}

    it 'should return all commits from Perforce depot' do
      perforce_class.instance_variable_set('@p4server.getChangelists', ['12345'])

      allow(perforce_class).to receive(:change_list).and_return(%w(12500 12600))

#      allow(Analytics::ReviewTools::CrucibleFetching).to receive(:all_revisions_in_review).with('CR-1').and_return(
#        %w(98c52f861081824bb9e54b4f16cc53a0cfbbda18 67e64c44202b058d6c057a9ce71d90e39f1eee23 d2b0df79b44d3de51a3ebc514cd8547eb79b739c))
#      allow(Analytics::ReviewTools::CrucibleFetching).to receive(:all_revisions_in_review).with('CR-5').and_return(%w(98c52f861081824bb9e54b4f16cc53a0cfbbda18 67e64c44202b058d6c057a9ce71d90e39f14723 bbc0df79b44d3de51a3ebc514cd8547eb79b739c))

      expect(subject).to be_a(Array)
      expect(subject.length).to eql(2)
      expect(subject.length).to be > 1

      perforce_class.instance_variable_set('@all_commits', ['12345'])
      expect(subject).to be_a_kind_of(Array)
      expect(subject.first).to eq '12345'
    end
  end

  context '#related_reviewed_objects' do
    subject{ perforce_class.related_reviewed_objects ['12345']}
    it 'should return all commits from Perforce depot' do
      perforce_class.instance_variable_set('@all_commits', ['12345'])
      expect(subject).to be_a_kind_of(Array)
      expect(subject.first).to eq '12345'
    end
  end

  context '#all_changes_in_revisions' do
    subject{ perforce_class.all_changes_in_revisions ['1']}
    it 'should return count of changed code line for revisions array' do
      expect(subject).to be_a_kind_of(Integer)
    end
  end

end
