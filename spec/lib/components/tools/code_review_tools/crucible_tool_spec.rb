# encoding : utf-8

require 'spec_helper'
require 'tools/code_review_tools/crucible_tool'
require 'fixtures/factories'
require 'pry'


RSpec.describe MGT::CrucibleTool do
  let(:crucible_class) { MGT::CrucibleTool }
  let(:crucible_tool_instance) {crucible_class.new(FactoryGirl.build(:testing_configs))}
  it 'should include module CodeReviewTool' do
    expect(crucible_class.included_modules).to include(MGT::CodeReviewTool)
  end

  it 'should include module AbstractTool' do
    expect(crucible_class.included_modules).to include(MGT::AbstractTool)
  end

  it 'inherited from BaseREST' do
    expect(crucible_class.ancestors).to include(MGT::BaseREST)
  end

  context '#escape_cru_project' do
    it 'should return escaped string ' do
      test = crucible_tool_instance.send(:escape_cru_project)
      expect(test).to be_a_kind_of(String)
      expect(test).to start_with('/rest-service')
      expect(test).to end_with('?project=set_project')
    end
  end

  context '#test_connection' do
    subject{ crucible_tool_instance.send(:test_connection) }

    it 'should return Unautorized message' do
      allow_any_instance_of(crucible_class).to receive(:send_GET_request) do
        FactoryGirl.build(:my_response, code: '401', msg: 'Unauthorized')
      end
      expect(subject).to eql('Please, check your credentials to Crucible system')
    end

    it 'should return Server problems message' do
      allow_any_instance_of(crucible_class).to receive(:send_GET_request) do
        FactoryGirl.build(:my_response, code: '502')
      end
      expect(subject).to eql('Something going wrong on Crucible server side. Please, try later.')
    end

    it 'should return Project key error message' do
      allow_any_instance_of(crucible_class).to receive(:send_GET_request) do
        FactoryGirl.build(:my_response, code: '404')
      end
      expect(subject).to match(/Project  - set_project - is not found in Crucible/)
    end

    it 'should return nothing' do
      allow_any_instance_of(crucible_class).to receive(:send_GET_request) do
        FactoryGirl.build(:my_response, code: '200', msg: 'ok')
      end
      expect(subject).to eq(nil)
    end

    it 'should return Error Connection Rescue message' do
      allow_any_instance_of(crucible_class).to receive(:send_GET_request) do
        raise Errno::ECONNREFUSED
      end
      expect(subject).to start_with("Can't get access to")
    end

    it 'should return Error TimeOut rescue messgae' do
      allow_any_instance_of(crucible_class).to receive(:send_GET_request) do
        raise Errno::ETIMEDOUT
      end
      expect(subject).to end_with('Connection timed out')
    end
  end

  context '#all_closed_reviews' do
    subject{ crucible_tool_instance.send(:all_closed_reviews) }

    it 'should return 2 values in array' do
      allow_any_instance_of(MGT::CrucibleTool).to receive(:escape_cru_project) do
        '/rest-service/reviews-v1/filter/details?project=CR'
      end
      allow_any_instance_of(MGT::CrucibleTool).to receive(:send_GET_request) do
        FactoryGirl.build(:my_response, code: '200', msg: 'ok')
      end
      allow_any_instance_of(MGT::CrucibleTool).to receive(:parse_response) do
        JSON.parse(File.read(File.expand_path('spec/fixtures/for_crucible/all_closed_reviews(crucible_git)_fixture.json')))
      end
      expect(subject).to be_kind_of(Array)
      expect(subject.length).to eq 2
    end
  end

  context '#all_revisions in review' do
    subject{ crucible_tool_instance.send(:all_revisions_in_review, 'CR-5') }

    it 'should return 3 uniq revisions' do
      allow_any_instance_of(MGT::CrucibleTool).to receive(:parse_response) do
        JSON.parse(File.read(File.expand_path('spec/fixtures/for_crucible/all_revision_in_review(crucible_git)_fixture.json')))
      end
      allow_any_instance_of(MGT::CrucibleTool).to receive(:send_GET_request) do
        FactoryGirl.build(:my_response, code: '200', msg: 'ok')
      end
      expect(subject).to be_an_instance_of(Array)
      expect(subject.length).to eq(3)
      expect(subject).not_to be_empty
      expect(subject).to match_array(%w(98c52f861081824bb9e54b4f16cc53a0cfbbda18 67e64c44202b058d6c057a9ce71d90e39f1eee23 d2b0df79b44d3de51a3ebc514cd8547eb79b739c))
    end
  end

  context '#array_of_revisions' do
    subject{ crucible_tool_instance.send(:array_of_revisions) }

    it 'should return 5 review revisions on 2 closed review request' do
      allow_any_instance_of(crucible_class).to receive(:all_closed_reviews_for_range).and_return(%w(CR-1 CR-5))

      allow_any_instance_of(crucible_class).to receive(:all_revisions_in_review).with('CR-1').and_return(
                                                             %w(98c52f861081824bb9e54b4f16cc53a0cfbbda18 67e64c44202b058d6c057a9ce71d90e39f1eee23 d2b0df79b44d3de51a3ebc514cd8547eb79b739c))
      allow_any_instance_of(crucible_class).to receive(:all_revisions_in_review).with('CR-5').and_return(%w(98c52f861081824bb9e54b4f16cc53a0cfbbda18 67e64c44202b058d6c057a9ce71d90e39f14723 bbc0df79b44d3de51a3ebc514cd8547eb79b739c))
      expect(subject).to be_a(Array)
      expect(subject.length).to eql(5)
      expect(subject.length).to be > 4
    end
  end

end