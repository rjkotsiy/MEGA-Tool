# encoding: utf-8

require_relative '../spec_helper.rb'
require 'components/review_tools/review-board-fetch'
require_relative '../fixtures/factories'
require 'faker'

RSpec.describe Analytics::ReviewTools::ReviewBoardFetching do
  let(:main_class){Analytics::ReviewTools::ReviewBoardFetching}
  subject{Analytics::ReviewTools::ReviewBoardFetching}

  it { is_expected.to respond_to(:opt, :url, :user) }

  context '#review_board_information' do
    pending 'Waiting for server ))'
  end

  context '#fullname_join_email' do
    subject{main_class.fullname_join_email}
    it 'should return string in such format' do
      mail = Faker::Internet.free_email
      main_class.user = {'fullname' => 'FullName','email' => "#{mail}"}
      expect(subject).to be_a_kind_of(String)
      expect(subject).to eql("FullName -- #{mail}")
    end
  end

  context '#return_value_unless_object_nil' do
    it 'should return correct value' do
      expect(subject.return_value_unless_object_nil({'name' => 'My_name'}, 'name')).to eql('My_name')
      expect(subject.return_value_unless_object_nil(nil, 'name')).to_not be_truthy
    end
  end

  context '#execute_method_unless_obj_nil' do
    subject{main_class.execute_method_unless_obj_nil(:target_people_iterating, ['one', 'two'])}
    it 'should call method if object exists' do
      allow(main_class).to receive(:user_extra_information).and_return(true)
      allow(main_class).to receive(:fullname_join_email).and_return('FullName -- fullname@example.com')
      array = ['FullName -- fullname@example.com', 'FullName -- fullname@example.com']
      expect(subject).to be_an(Array)
      expect(subject.length).to eql(2)
      expect(subject).to eql(array)
    end
  end

  context '#fullname_and_email' do
    subject{main_class.fullname_and_email({'title'=>'No_name_title','fullname' => 'FullName','email' => 'fullname@example.com'})}
    it { is_expected.to be_an(Array) }
    it 'should contain two elements' do
      expect(subject.length).to eql 2
    end
    it { is_expected.to contain_exactly('FullName', 'fullname@example.com') }
    it { is_expected.to all(be_a(String)) }
  end

  context '#to_array' do
    subject{main_class.to_array}
    it 'should have structure for output' do
      allow(main_class).to receive(:review_board_information).and_return([[1,2,3,4],[4,5,6,7,8]])
      expect(subject).to an_instance_of(Array)
      expect(subject.first).to all( be_an(String) )
      expect(subject.first).to include('Submitter email', 'Summary')
      expect(subject.length).to eql 3
    end
  end

  context '#user_extra_information' do
    subject{ main_class.user_extra_information('user') }
    it 'should return extra info about current user' do
      # obj = {'firstname' => Faker::Name.first_name, 'last_name' => Faker::Name.last_name, 'avatar' => 'link_to', 'email' => Faker::Internet.email}
      # allow(main_class).to receive_message_chain(:send_my_own_request, :body) {true}
      # allow(main_class).to receive(:parse_response).and_return(
      #   {'user' => obj,
      #    'title' => {'admin' => true, 'pass' => 'my_pass'}
      #   })
      # expect(main_class.user).to eql(obj)
    end
  end

  context '#review_board_information' do
    subject{ main_class.review_board_information }
    it 'should return an Array' do
      allow(main_class).to receive_message_chain(:send_my_own_request, :body).and_return([{}])
      allow(main_class).to receive(:parse_response).and_return({'review_requests' => [:one, 'one', :two, 'two']})
      allow(main_class).to receive(:argument_collector).and_return([:one, 'one', :two, 'two'])
      expect(subject).to all(be_an(Analytics::ReviewTools::ReviewBoardStructure))
    end
  end

  context '#try' do
    subject{main_class.try(FactoryGirl.build :testing_configs)}
    it 'should return Unautorized message' do
      allow(main_class).to receive(:send_my_own_request).with('/api/review-requests/') do
        FactoryGirl.build(:my_response, code: '401', msg: 'UNAUTHORIZED')
      end
      expect(subject).to eql('Please, check your credentials to Review Board system')
    end

    it 'should return server side problem message' do
      allow(main_class).to receive(:send_my_own_request).with('/api/review-requests/') do
        FactoryGirl.build(:my_response, code: '502')
      end
      expect(subject).to eql('Something going wrong on Review Board server side. Please, try later.')
    end

    it 'should return empty array' do
      allow(main_class).to receive(:send_my_own_request).with('/api/review-requests/') do
        FactoryGirl.build(:my_response, code: '200', msg: 'OK')
      end
      expect(subject).to be_an(Array)
      expect(subject).to be_empty
    end

    it 'should return Error Connection Rescue message' do
      allow(main_class).to receive(:send_my_own_request) do
        raise Errno::ECONNREFUSED
      end
      expect(subject).to end_with('Connection refused')
    end

    it 'should return Time Out Rescue message' do
      allow(main_class).to receive(:send_my_own_request).and_raise(Errno::ETIMEDOUT)
      expect(subject).to match(/Connection timed out/)
    end
  end
end