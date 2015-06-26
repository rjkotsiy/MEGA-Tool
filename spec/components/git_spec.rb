# encoding: utf-8

require 'spec_helper'
require 'components/scm/adapters/git_fetch'
require 'fixtures/factories'

describe Analytics::Scm::Adapters::GitFetching do

  def stub_useless_methods
    allow(tested_class).to receive(:encode_folder_name).and_return('Encoded string')
    allow(tested_class).to receive(:local_location_of_repository).and_return('path')
  end

  let(:tested_class) { Analytics::Scm::Adapters::GitFetching }
  subject{ Analytics::Scm::Adapters::GitFetching  }

  it { is_expected.to respond_to(:params) }

  context '#try' do
    subject{ tested_class.try(FactoryGirl.build :testing_configs) }

    it 'is success with incoming parameters' do
      allow(tested_class).to receive(:initialize_or_pull_repository).and_return(true)
      stub_useless_methods
      expect(subject).to be_an_instance_of(String)
      expect(subject).to be_empty
    end

    it 'is fail with invalid credentials' do
      stub_useless_methods
      allow(tested_class).to receive(:initialize_or_pull_repository).and_raise(Git::GitExecuteError)
      expect(subject).to eql('Permission denied for Git system.')
      expect(subject).to match(/Permission denied for Gi/)
    end
  end

  context '#all_commits' do
    subject{ tested_class.all_commits(Time.parse('5 Nov 2014'),Time.now) }
    it 'return all commits from repository' do
      stub_useless_methods
      allow(tested_class).to receive(:initialize_or_pull_repository).and_return(Git::Base.new)
      allow_any_instance_of(Git::Base).to receive_message_chain(:log, :since, :until) do
        FactoryGirl.build(:all_commits_git)
      end
      expect(subject).to an_instance_of(Array)
      expect(subject.length).to eql 5
    end
  end

  context '#initialize_or_pull_repository' do
    subject{ tested_class.send(:initialize_or_pull_repository, 'encoded', 'Path') }
    it 'should return instance of Git repository with path' do
      allow(Dir).to receive(:exist?).and_return(true)
      allow(Git).to receive(:open).and_return (Git::Base.new)
      allow_any_instance_of(Git::Base).to receive(:reset).and_return(self)
      allow_any_instance_of(Git::Base).to receive(:pull).and_return(Git::Base.new)
      expect(subject).to be_a(Git::Base)
    end
    it 'should return instance of Git repository without path' do
      allow(Dir).to receive(:exist?).and_return(false)
      allow(Git).to receive(:clone).and_return(Git::Base.new)
      expect(subject).to be_a(Git::Base)
    end
  end

  context '#raw_commit_structure' do
    it 'should return Structure of Raw Git Commit' do
      commit = double(OpenStruct, :author => OpenStruct.new({'name' => Faker::Internet.user_name, 'email' => Faker::Internet.email}), :message => 'Hello world', :committer_date => Time.now)
      expect(tested_class.send(:raw_commit_structure, commit)).to be_an_instance_of(Analytics::Scm::GitCommit)
    end
  end

  context '#other_file_info' do
    it 'should return other file info' do
      expect(tested_class.send(:other_file_info, {}, 'path', {})).to an_instance_of( Analytics::Scm::AddDeleteGITInfo)
    end
  end

  context '#fetch_all_information' do
    subject{ tested_class.fetch_all_information }
    it 'should return all commits' do
      allow(tested_class).to receive(:all_commits).and_return(FactoryGirl.build(:all_commits_git))
      allow(tested_class).to receive(:type_of_modifications).and_return('Empty', 'Allow', 'some', 're')
      allow(tested_class).to receive(:fetching_other_file_information).and_return([12,4,5,7])
      allow(tested_class).to receive(:raw_commit_structure).and_return('Success')
      expect(subject).to be_an(Array)
      expect(subject).not_to be_empty
    end
  end

  context '#to_array' do
    subject{ tested_class.send(:to_array) }
    it 'should return array of particular structure for output' do
      allow_any_instance_of(OpenStruct).to receive(:to_a).and_return(['modified', 12, 2, 12])
      allow(tested_class).to receive(:fetch_all_information) do
        [FactoryGirl.build(:my_response, author_name: 'Bogdan Naumenko',
                                         author_email:'groovejbogdan@yandex.ru',
                                         message:'Some modification',
                                         rev_hash:'2b0a63a347fd442e73885c897fe82c82e1f266bb',
                                         timestamp:'2014-12-30 14:49:14 +0200',
                                         changes: { 'Gemfile' => FactoryGirl.build(:my_response, modification_type: 'new',                        added_str: 5, deleted_str: 0, changedMAX: 5) }
                          ),
         FactoryGirl.build(:my_response, author_name:'Bogdan Naumenko',
                                       author_email:'groovejbogdan@yandex.ru',
                                      message: 'add some gems for testing models',
                                      rev_hash:'ac47e41577e1f1776af2769b48f09d05b7f33e53',
                                      timestamp:'2014-12-29 17:32:46 +0200',
                                      changes:{ 'app/controllers/to_do_lists_controller.rb'=>FactoryGirl.build(:my_response, modification_type:'modified', added_str:12, deleted_str:1, changedMAX:12) })
        ]
      end
      expect(subject).to an_instance_of(Array)
      expect(subject).to all(be_an(Array))
      expect(subject.first).to all(an_instance_of(String))
      expect(subject.first.first).to eql('Commiter-name')
      expect(subject.length).to eql 3
      expect(subject.last).to contain_exactly( 'Bogdan Naumenko', 'groovejbogdan@yandex.ru', 'add some gems for testing models', 'ac47e41577e1f1776af2769b48f09d05b7f33e53', '2014-12-29 17:32:46 +0200', 'app/controllers/to_do_lists_controller.rb', 'modified', 'to_do_lists_controller.rb', 'rb', 12, 2, 12)
      expect(subject.last.last).to a_kind_of(Numeric)
      expect(subject.last.last).to eql 12
      expect(subject.last[7]).to eql('to_do_lists_controller.rb')
    end

  end

end