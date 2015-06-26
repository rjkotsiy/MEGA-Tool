# encoding : utf-8

require_relative '../spec_helper.rb'
require 'components/project_management/rally-fetch'
require_relative '../fixtures/factories'

RSpec.describe Analytics::ProjectManagement::RallyFetching do
  let(:rally_class) {Analytics::ProjectManagement::RallyFetching}
  subject{ Analytics::ProjectManagement::RallyFetching }

  it { is_expected.to respond_to(:params)}

  context '#try' do
    subject{rally_class.try(FactoryGirl.build :testing_configs)}
    it 'return rally object with correct credentials' do
      allow(rally_class).to receive(:rally_client).and_return(RallyAPI::RallyRestJson.new({}))
      expect(subject).to be_a_kind_of(RallyAPI::RallyRestJson)
    end

    it 'return error with bad credentials' do
      allow(rally_class).to receive(:rally_client).and_raise(StandardError)
      expect(subject).to be_a(String)
      expect(subject).to eql('The username or password or project name or workspace you entered is incorrect for Rally. Please check your credentials or expired date for your account.')
    end
  end

  context '#headers' do
    subject{ rally_class.send(:headers)}
    it { is_expected.to be_an_instance_of(RallyAPI::CustomHttpHeader)}
  end

  context '#rally_client' do
    subject{ rally_class.send(:rally_client)}
    it { is_expected.to be_a(RallyAPI::RallyRestJson) }
  end

  context '#query_object' do
    subject{ rally_class.send(:query_object)}
    it { is_expected.to be_a_kind_of(RallyAPI::RallyQuery) }
  end

  context '#basic_query_things' do
    subject{ rally_class.send(:basic_query_things, ['a', 'c']) }
    it 'return basic object for query' do
      allow(rally_class).to receive(:query_object).and_return(RallyAPI::RallyQuery.new({}))
      allow_any_instance_of(RallyAPI::RallyRestJson).to receive_message_chain('rally_default_project.rally_object').and_return({'_ref' => 'Reference'})
      allow_any_instance_of(RallyAPI::RallyQuery).to receive(:build_query_segment).and_return('Builted')
      expect(subject.type).to eql('defect')
      expect(subject.project_scope_up).to be_falsy
      expect(subject.project_scope_down).to eql(false)
      expect(subject.page_size).to eql(500)
      expect(subject.project).to eql('_ref' => 'Reference')
      expect(subject).to be_an_instance_of(RallyAPI::RallyQuery)
    end
  end

  context '#calculate_points' do
    subject{ rally_class.send(:calculate_points, Array.new(4, RallyAPI::RallyRestJson.new({}))) }
    it 'return total amount' do
      allow_any_instance_of(RallyAPI::RallyRestJson).to receive_message_chain('read.rally_object').and_return({'PlanEstimate' => false}, {'PlanEstimate' => 12}, {'PlanEstimate' => 12}, {'PlanEstimate' => 1}, {'PlanEstimate' => 1}, {'PlanEstimate' => 10}, {'PlanEstimate' => 10})
      expect(subject).to eql(23)
    end
  end

  context '#result_by_query' do
    subject{ rally_class.send(:result_by_query, 'my_string')}
    it 'return array of objects' do
      allow_any_instance_of(RallyAPI::RallyRestJson).to receive(:find).and_return([{'one'=>1}, {'two'=>2} ])
      expect(subject).to be_an_instance_of(Array)
      expect(subject.length).to eql(2)
    end
  end

  context '#repeated_strings_params' do
    subject{ rally_class.send(:repeated_strings_params) }
    it 'return Array with needed elements' do
      expect(subject).to be_a(Array)
      expect(subject.length).to eql(3)
      expect(subject.first).to include('ationDate')
      expect(subject.last).to eql('State != Closed')
    end
  end

  context '#to_array' do
    subject{ rally_class.to_array }
    it 'return Array structure for output' do
      allow(rally_class).to receive(:known_defect_query).and_return('')
      allow(rally_class).to receive(:technical_debt_query).and_return('')
      allow(rally_class).to receive(:technical_dept_backlog_size).and_return('')
      allow(rally_class).to receive(:result_by_query).and_return(RallyAPI::RallyRestJson.new({}))
      allow(rally_class).to receive(:calculate_points).and_return(15, 22)
      allow_any_instance_of(RallyAPI::RallyRestJson).to receive(:total_result_count).and_return(4)
      expect(subject).to be_a_kind_of(Array)
      expect(subject.length).to eql(4)
      expect(subject.first).to include('Points')
      expect(subject.last.length).to eql(2)
      expect(subject.last.last).to be >= 4
      expect(subject[1].last).to eql(15)
      expect(subject[1].first).to end_with('Estimate')
      expect(subject[2].last).to eql(22)
    end
  end
end