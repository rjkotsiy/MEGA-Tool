# encoding: utf-8

require 'spec_helper.rb'
require 'components/project_management/jira-fetch'
require 'fixtures/factories'

describe Analytics::ProjectManagement::JiraRemote do
  let(:jira_class){ Analytics::ProjectManagement::JiraRemote }
  subject{ Analytics::ProjectManagement::JiraRemote }

  it { is_expected.to respond_to(:obj, :jira_access_client, :inc_params, :basic_query_params) }

  context '#try' do
    subject{ jira_class.try(FactoryGirl.build(:testing_configs, jira_employees: ['dshum','vmakar'], jira_statuses: ['Closed'], jira_priorities: ['Low', 'Mediun', 'High'], jira_issue_types: ['Defect', 'Sub-defect'], jira_statuses: [])) }
    before(:each) do
      basic_stashing
    end
    def basic_stashing
      allow(jira_class).to receive(:jira_client).and_return(JIRA::Client.new)
    end

    it 'return empty array if client was created' do
      allow(jira_class).to receive(:check_for_correct_jira_project).and_return([])
      allow_any_instance_of(JIRA::Client).to receive(:get) do
        FactoryGirl.build(:my_response, code: '200')
      end
      expect(subject).to be_a(Array)
      expect(subject).to be_empty
    end

    it 'return access rights error message' do
      allow_any_instance_of(JIRA::Client).to receive(:get) do
        FactoryGirl.build(:my_response, code: '403')
      end
      expect(subject.first).to match(/Please, check your access /)
    end

    it 'return server side problem' do
      allow_any_instance_of(JIRA::Client).to receive(:get) do
        FactoryGirl.build(:my_response, code: '502')
      end
      expect(subject.first).to match(/Something going wrong in JIRA server side/)
    end

    it 'return error with bad credentials' do
      allow_any_instance_of(JIRA::Client).to receive(:get).and_raise(JIRA::HTTPError.new(FactoryGirl.build(:my_response, code: '401')))
      expect(subject.first).to eql('Please check your credentials or right URL address for Jira')
      expect(subject.first).to start_with('Please check your credentials')
    end

    it 'return error with bad project' do
      allow(jira_class).to receive(:check_for_correct_jira_project).and_return(['Please, check JIRA Project Name'])
      allow_any_instance_of(JIRA::Client).to receive(:get) do
        FactoryGirl.build(:my_response, code: '200', msg: 'Ok')
      end
      expect(subject.length).to eql 1
      expect(subject.first).to match(/Project/)
    end
  end

  context '#check_for_correct_jira_project' do
    subject{ jira_class.send(:check_for_correct_jira_project, []) }

    it 'return error with incorrect project name' do
      allow_any_instance_of(JIRA::Client).to receive_message_chain(:Project, :find) do
        raise JIRA::HTTPError.new(FactoryGirl.build(:my_response, code: '404'))
      end
      expect(subject.first).to be_an(String)
      expect(subject).to contain_exactly('Please, check JIRA Project Name')
      expect(subject.first).to end_with('Name')
    end

    it 'return empty array if project is correct' do
      allow_any_instance_of(JIRA::Client).to receive_message_chain(:Project, :find).and_return('Clear')
      expect(subject).to be_empty
    end
  end

  context '#array_to_string' do
    context 'return string with one element in array' do
      subject{ jira_class.send(:array_to_string, [11], 'defect') }
      it { is_expected.to be_a(String) }
      it { is_expected.to eql("defect='11'")}
    end
    context 'return string with many elements in array' do
      subject{ jira_class.send(:array_to_string, [11,22,33], 'defect')}
      it { is_expected.to be_an(String) }
      it { is_expected.to eql("defect in ('11','22','33')")}
    end
  end

  context '#creating_jql_string' do
    before(:each) { actions }
    def actions
      allow(jira_class).to receive(:array_to_string).with([2],'task').and_return("task='2'")
    end

    it 'return string with incoming array, empty string' do
      expect(jira_class.send(:creating_jql_string, [2], '', 'task')).to eql("task='2'")
    end
    it 'add some value to exiting string' do
      expect(jira_class.send(:creating_jql_string, [2], 'project=SEMA', 'task')).to eql(" AND task='2'")
    end
  end

  context '#add_project_name_to_jql' do
    before(:each) { set_project_name }
    def set_project_name
      allow(jira_class).to receive_message_chain(:inc_params, :jira_project).and_return('SEMA')
    end

    it 'return string with project only' do
      expect(jira_class.send(:add_project_name_to_jql, '')).to eql('project=SEMA')
    end

    it 'add project name to existing string' do
      expect(jira_class.send(:add_project_name_to_jql, "sub-task in ('2', '4')")).to eql("project=SEMA AND sub-task in ('2', '4')")
    end
  end

  context '#initializing_jql_string' do
    subject{ jira_class.send(:initializing_jql_string) }
    it { is_expected.to eql("assignee in ('dshum','vmakar') AND priority in ('Low','Mediun','High') AND issuetype in ('Defect','Sub-defect')") }
  end

  context '#jira_client' do
    subject{ jira_class.send(:jira_client, 'login', 'pass', 'url')}
    it { is_expected.to an_instance_of(JIRA::Client) }
  end

  context '#division_if_not_nil' do
    it 'return number in hours' do
      expect(jira_class.send(:division_if_not_nil, 7200)).to eql 2
    end

    it 'it return 0 without incoming number' do
      expect(jira_class.send(:division_if_not_nil, nil)).to eql 0
    end
  end

  context '#return_method_from_obj_if_obj_not_nil' do
    it 'return :name method from object if method defined' do
      expect(jira_class.send(:return_method_from_obj_if_obj_not_nil, FactoryGirl.build(:my_response, name: 'My_name'))).to an_instance_of(String)
      expect(jira_class.send(:return_method_from_obj_if_obj_not_nil, FactoryGirl.build(:my_response, name: 'My_name'))).to eql('My_name')
    end

    it 'return method from object' do
      expect(jira_class.send(:return_method_from_obj_if_obj_not_nil, FactoryGirl.build(:my_response, last: 'Last_name'), 'last')).to eql('Last_name')
    end
  end

  context '#time_parsing' do
    subject{ jira_class.send(:time_parsing, '2014-10-30 12:25:36 +0200') }
    it { is_expected.to an_instance_of(Time) }
  end

  def all_my_issues_in_array
    allow(jira_class).to receive(:issues_by_jql) do
      Marshal.load File.read(File.expand_path('spec/fixtures/for_jira/issue_by_jql.txt'))
    end
  end

  context '#fetching' do
    subject{ jira_class.fetching }
    before(:each) do
      stub_actions
    end

    def stub_actions
      allow(jira_class).to receive(:add_project_name_to_jql).and_return('project=SEMA')
      allow(jira_class).to receive(:initializing_jql_string).and_return('')
      all_my_issues_in_array
    end

    it 'change basic_query_params[:fields]' do
      expect {subject}.to change {jira_class.basic_query_params[:fields]}.from({}).to(['assignee','key','status','issuetype','priority','customfield_10002','timeoriginalestimate','aggregatetimespent'])
    end

    it 'return Array with some structures' do
      expect(subject).to be_a(Array)
      expect(subject).to all( be_an Analytics::ProjectManagement::JiraStructure )
    end
  end

  context '#to_array' do
    subject { jira_class.to_array}
    it 'return array for output' do
      allow(jira_class).to receive(:fetching) do
        Array({:a => "a", :b => "b", :c => "c", :d => "d"})
      end
      expect(subject).to be_a Array
      expect(subject.first).to all( be_an(String) )
      expect(subject.first).to include('Status', 'Issue Type')
      expect(subject.length).to eql 5
      expect(subject.last).to eql([:d, "d"])
    end
  end

  context '#add_range_to_jql' do
    subject{ jira_class.send(:add_range_to_jql, 'my_string') }
    it 'should add time range for jql string' do
      allow(jira_class).to receive_message_chain(:inc_params, :jira_sprint_start_date).and_return('2014/09/20')
      allow(jira_class).to receive_message_chain(:inc_params, :jira_sprint_end_date).and_return('2015/04/01')
      expect(subject).to start_with('my_string')
      expect(subject).to end_with('01\'')
      expect(subject).to eql("my_string and created >= '2014/09/20' and created <= '2015/04/01'")
    end
  end

  context '#issues_by_jql' do
    subject { jira_class.send(:issues_by_jql, 'projetc=MT') }
    it 'return array of issues' do
      allow(jira_class).to receive_message_chain(:"jira_access_client.Issue.jql") do
        Marshal.load File.read(File.expand_path('spec/fixtures/for_jira/issue_by_jql.txt'))
      end
      expect(subject).to be_an_instance_of Array
    end
  end

  context '#count_estimation' do
    subject { jira_class.send(:count_estimation, 'project=MARK')}
    it 'return number' do
      all_my_issues_in_array
      expect(subject).to be_a(Array)
      expect(subject.first).to eql(57)
      expect(subject.first).to be >= 0
      expect(subject[-1]).to be_zero
      expect(subject[0]).to be_odd
    end
  end

  context '#defects_and_others' do
    subject { jira_class.defects_and_others }
    before(:each) {
      tech_dept_actions
    }

    def tech_dept_actions
      allow(jira_class).to receive_message_chain('issues_by_jql.size').and_return(7)
      allow(jira_class).to receive(:count_estimation).and_return(21, 32)
      allow(jira_class).to receive(:inc_params) do
        FactoryGirl.build(:my_response, jira_project: 'SDOA', jira_dept_def_params: {'sprint_start_date' => '2010/09/20', 'sprint_end_date' => '2014/12/10'} )
      end
    end

    it 'return expected values' do
      expect(subject.first[0]).to start_with('Known Defects Estimate - ')
      expect(subject[1]).to contain_exactly('', '0', '1')
      expect(subject.last).to include('', '7')
    end

    it 'change basic_query_params[:fields]' do
      jira_class.basic_query_params[:fields] = {}
      expect {subject}.to change {jira_class.basic_query_params[:fields]}.from({}).to(['timeoriginalestimate', 'customfield_10002'])
    end

    it {is_expected.to be_an Array}
    it {is_expected.to all(be_a(Array))}

    it 'return array with 3 arrays' do
      expect(subject.length).to eql(8)
    end
  end


end