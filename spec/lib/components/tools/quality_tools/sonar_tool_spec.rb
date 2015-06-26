# encoding : utf-8

require 'spec_helper'
require 'tools/quality_tools/sonar_tool'
require 'fixtures/factories'

RSpec.describe MGT::SonarqubeTool do
  let(:sonar_class) { MGT::SonarqubeTool }
  let(:sonar_tool_instance) { MGT::SonarqubeTool.new(FactoryGirl.build(:testing_configs))}

  it 'should include module QualityTool' do
    expect(sonar_class.included_modules).to include(MGT::QualityTool)
  end

  it 'should include module AbstractTool' do
    expect(MGT::SonarqubeTool.included_modules).to include(MGT::AbstractTool)
  end

  it 'inherited from BaseREst' do
    expect(sonar_class.ancestors).to include(MGT::BaseREST)
  end

  it 'should be a Sonarqube tool' do
    expect(sonar_tool_instance.tool_name).to eq('Sonarqube')
  end

  context '#test_connection' do
    subject{ sonar_tool_instance.test_connection }

    it 'should return Unauthorized message' do
      allow_any_instance_of(sonar_class).to receive(:send_GET_request) do
        FactoryGirl.build(:my_response, code: '401', msg: 'Unauthorized')
      end
      expect(subject).to eql('Please, check your credentials to Sonarqube system')
    end

    it 'should return server side problem message' do
      allow_any_instance_of(sonar_class).to receive(:send_GET_request) do
        FactoryGirl.build(:my_response, code: '502')
      end
      expect(subject).to eql('Something going wrong on Sonarqube server side. Please, try later.')
    end

    it 'should return project name error message' do
      allow_any_instance_of(sonar_class).to receive(:send_GET_request) do
        FactoryGirl.build(:my_response, code: '404')
      end
      expect(subject).to match(/Project  - /)
    end

    it 'should return nothing' do
      allow_any_instance_of(sonar_class).to receive(:send_GET_request) do
        FactoryGirl.build(:my_response, code: '200', msg: 'OK')
      end
      expect(subject).to be_an(NilClass)
      expect(subject).to be_falsy
    end

    it 'return connection refused exception message' do
      allow_any_instance_of(sonar_class).to receive(:send_GET_request) do
        raise Errno::ECONNREFUSED
      end
      expect(subject).to be_a(String)
      expect(subject).to start_with("Can't get access to Sonarqube")
    end

    it 'return timeout exception message' do
      allow_any_instance_of(sonar_class).to receive(:send_GET_request).and_raise(Errno::ETIMEDOUT)
      expect(subject).to be_a(String)
      expect(subject).to end_with('Connection timed out')
    end
  end

  context '#path_with_project_name' do
    subject{ sonar_tool_instance.send(:path_with_project_name) }
    it 'return string with project if project exists' do
      sonar_tool_instance.instance_variable_set('@project', 'Display')
      expect(subject).to be_a(String)
      expect(subject).to eql('/api/resources?resource=Display&metrics=ncloc,duplicated_lines,blocker_violations,critical_violations,major_violations')
      expect(subject).to include('Display')
    end

    it 'return string without project name' do
      sonar_tool_instance.instance_variable_set('@project', nil)
      expect(subject).to be_a_kind_of(String)
      expect(subject).to eql('/api/resources?metrics=ncloc,duplicated_lines,blocker_violations,critical_violations,major_violations')
      expect(subject).not_to include('resource=')
    end
  end

  context '#sonar_dashboard_information' do
    subject{ sonar_tool_instance.send(:sonar_dashboard_information) }
    it 'return array with data' do
      allow_any_instance_of(sonar_class).to receive_message_chain(:send_GET_request, :body).and_return('return')
      allow_any_instance_of(sonar_class).to receive(:parse_response) do
        JSON.parse(File.read(File.expand_path('spec/fixtures/for_sonar/all_data_for_sonar.json')))
      end
      allow_any_instance_of(sonar_class).to receive(:argument_collector).and_return([1,2,3,4,5,6])
      expect(subject).to be_an(Array)
      expect(subject).to all(be_a_kind_of(MGT::SonarStructure))
    end
  end

  context '#argument_collector' do
    subject{ sonar_tool_instance.send(:argument_collector, FactoryGirl.build(:item_for_sonar)) }

    it { is_expected.to be_a(Array)}

    it 'return array with needed elements from object' do
      expect(subject).to contain_exactly('Web project analyzed with the SonarQube Runner', 35, 0, 0, 0, 1, 1)
      expect(subject.last).to eql(subject[3..5].reduce(:+))
    end
  end

  context '#to_array' do
    subject{ sonar_tool_instance.to_array }
    it 'should have structure for output' do
      allow_any_instance_of(sonar_class).to receive(:sonar_dashboard_information).and_return([['tre',1,2,3,4],['regb',4,5,6,7,8], ['fd',4,9,8,2,9]])
      expect(subject).to an_instance_of(Array)
      expect(subject.first).to include('Lines of Code', 'Duplicated Lines')
      expect(subject.first).to all( be_an(String) )
      expect(subject.length).to eql 5
    end
  end



end