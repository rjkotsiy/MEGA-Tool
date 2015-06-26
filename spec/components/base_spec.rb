# encoding: utf-8
require 'spec_helper'
require 'components/scm/adapters/base'
require 'fileutils'

RSpec.describe Analytics::Scm::Adapters::Base do
  subject(:main_class) {Analytics::Scm::Adapters::Base}
  let(:logger_file) {File.join(Dir.pwd, 'git_fetch.log')}

  context "#logger" do
    subject {main_class.logger('git_fetch')}

    it { is_expected.to be_a_kind_of(Logger) }

    it " procedure creating" do
      FileUtils.remove_file(logger_file,force=true)
      expect {subject}.to change{File.exist?(logger_file)}.from(false).to(true)
    end

    it "with extention '.log' " do
      expect(File.extname(logger_file)).to eq('.log')
    end

    it "with particular name" do
      expect(File.basename(logger_file)).to match(/git_fetch/)
    end
  end

  context "#file_name" do
    subject {main_class.file_name(logger_file)}

    it {is_expected.to be_an(String)}
    it {is_expected.to end_with('fetch.log')}
    it {is_expected.not_to be_empty}
  end

  context "#file_extension" do
    subject {main_class.file_extension(logger_file)}

    it {is_expected.to be_truthy}
    it {is_expected.to be_a(String)}
    it {is_expected.to eq('log')}
    it {is_expected.to match(/lo/)}
  end
end