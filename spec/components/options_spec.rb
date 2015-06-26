# encoding: utf-8
require 'spec_helper'
require 'options/options.rb'
require 'chronic'


RSpec.describe Analytics::Options do

  time = Time.now

  subject do
    @options = {}
    @options[:from] = Chronic.parse(ENV['FROM']) || Time.parse("1 Jan 1970")
    @options[:to] = Chronic.parse(ENV['TO']) || time
    @options[:users] = ENV['USERS'] || nil
    @options[:type] = ENV['TYPE'] || nil
    @options[:branch] = ENV['BRANCH'] || nil
    @options[:filename] = ENV['FILENAME'] || nil
    @options[:output] = ENV['OUTPUT'] || nil

    if @options[:from] > @options[:to]
      @options[:from], @options[:to] = @options[:to], @options[:from]
    end
    @options
  end

  it { is_expected.to include(:from) }
  it { is_expected.to include(:to) }
  it { is_expected.to have_key(:users) }
  it { is_expected.to have_key(:type) }
  it { is_expected.to include(:branch) }
  it { is_expected.to include(:filename) }
  it { is_expected.to have_key(:output) }
  it { is_expected.not_to  include(:else_key) }
  it { is_expected.to be_kind_of(Hash) }

  it "Should return parsed :from value or return fix value"do
    expect(subject[:from]).to satisfy { |from| from == Chronic.parse(ENV['FROM']) || from == Time.parse("1 Jan 1970") || from == Chronic.parse(ENV['TO']) || from == time}
  end

  it "Should return parsed :to value or Time.now" do
    expect(subject[:to]).to satisfy { |to| to == Chronic.parse(ENV['TO']) || to == time || to == Chronic.parse(ENV['FROM']) || to == Time.parse("1 Jan 1970") }
  end

  it ":from shoud be kind of Time class" do
    expect(subject[:from]).to be_an(Time)
  end

  it ":from should be greater than :to" do
    expect(subject[:from]).to be < subject[:to]
  end

end