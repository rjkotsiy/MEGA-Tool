# encoding: utf-8
require 'spec_helper'
require 'components/scm/differences.rb'

RSpec.describe Analytics::Scm::Diff do

  context "#added_deleted_count" do
    subject {
      obj = Analytics::Scm::Diff.new
      array = ['@@dscsdcsd', '-fdfv', 'dfdfvdf' , "   dfvdfv", "+dfvdf", '-dfvdfvdf', "-fdff", "+dfvdfv"]
      obj.added_deleted_count(array)
    }

    it { is_expected.to be_truthy }
    it { is_expected.to be_an Array}

    it "should include three elements" do
      expect(subject.size).to eq (3)
    end

    it "should raise Error with wrong argument type" do
      obj = Analytics::Scm::Diff.new
      expect {obj.added_deleted_count('some_string')}.to raise_error NoMethodError
    end

    it "should return 2 added strings" do
      expect(subject[0]).to eq(2)
    end

    it "should return 3 deleted strings" do
      expect(subject[1]).to eq(3)
    end

    it "element of returning array should be Integer" do
      expect(subject[0]).to be_a_kind_of(Integer)
    end
  end

end