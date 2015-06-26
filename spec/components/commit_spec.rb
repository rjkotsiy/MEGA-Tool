# encoding: utf-8
require 'spec_helper.rb'
require 'components/scm/commit.rb'
require 'chronic'
require 'pry'

RSpec.describe Analytics::Scm::SvnCommit do
  describe "#escape_characters" do
    subject {Analytics::Scm::SvnCommit.escape_characters("sobolev.ov, amarreumi@gmail.com")}
    it { is_expected.to be_truthy }
    it { is_expected.to be_an String}
    it { is_expected.not_to be_empty }
    it { is_expected.not_to be_nil}
    it { is_expected.to include("sobolev", "gmail")}
    it { is_expected.to match(/obol/)}
    it "should escape characters" do
      str = "sobolev.ov, amarreumi@gmail.com"
      arr = str.split(", ")
      arr.map do |item|
        Regexp.escape(item)
      end
      expect(subject).to eq arr.join("|")
    end
  end

  describe '#filtering' do
    before (:context) do
      Filter = Struct.new(:from, :to, :users, :type, :branch, :filename)
    end

    subject do
      YAML.load_file(File.join(Dir.pwd, 'spec', 'fixtures', 'repo_data_for_commit.yml'))
    end

    it 'return all commits with empty filters' do
      filter = Filter.new(Time.parse('1 Jan 1970'), Time.now, nil, nil, nil, nil)
      result = Analytics::Scm::SvnCommit.filtering(subject, filter)
      expect(result.size).to eq(subject.size)
    end

    context 'Return result by current user = sobolev' do

      it 'should return return all commits current user' do
        filter = Filter.new(Time.parse('1 Jan 1970'), Time.now, 'sobolev.ov', nil, nil, nil)
        result = Analytics::Scm::SvnCommit.filtering(subject, filter)
        expect(result.size).to eq(139)
      end

      it 'should return return all commits current user by 1 year' do
        filter = Filter.new(Chronic.parse('01/01/2012'), Chronic.parse('01/01/2013'), 'sobolev.ov', nil, nil, nil)
        result = Analytics::Scm::SvnCommit.filtering(subject, filter)
        expect(result.size).to eq(21)
      end

      it 'sholud return all commits .hs files'  do
        filter = Filter.new(Time.parse('1 Jan 1970'), Chronic.parse('5/4/2014'), 'sobolev.ov', 'xml', nil, nil)
        result = Analytics::Scm::SvnCommit.filtering(subject, filter)
        expect(result.size).to eq(36)
      end
    end

    it "should return all commits users 'sobolev.ov, amaurremi'" do
      filter = Filter.new(Time.parse("1 Jan 1970"), Chronic.parse('3/2/2014'), 'sobolev.ov, amaurremi', nil, nil, nil)
      result = Analytics::Scm::SvnCommit.filtering(subject, filter)
      expect(result.size).to eq(289)
    end

    it 'should return all commits .xml files'  do
      filter = Filter.new(Time.parse("1 Jan 1970"), Chronic.parse('5/01/2015'), nil , 'xml', nil, nil)
      result = Analytics::Scm::SvnCommit.filtering(subject, filter)
      expect(result.size).to eq(50)
    end

    it 'should return all commits .xml and .java files by year'  do
      filter = Filter.new(Chronic.parse('5/27/2013'), Chronic.parse('5/27/2014'), nil , 'xml, java', nil, nil)
      result = Analytics::Scm::SvnCommit.filtering(subject, filter)
      expect(result.size).to eq(17)
    end

    it "should return filter all file name = LIKE ('haskel') from all period" do
      filter = Filter.new(Time.parse("1 Jan 1970"), Chronic.parse('yesterday'), nil , nil , nil, 'haskel')
      result = Analytics::Scm::SvnCommit.filtering(subject, filter)
      expect(result.size).to eq(153)
    end

    it 'should return filter all by branch name (take all from trunk.There are no brabnches in current repo)' do
      filter = Filter.new(Time.parse("1 Jan 1970"), Chronic.parse('3/20/2014'), nil, nil, 'trunk', nil)
      result = Analytics::Scm::SvnCommit.filtering(subject, filter)
      expect(result.size).to eq(309)
    end

  end
end