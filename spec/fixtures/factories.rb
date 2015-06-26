# encoding : utf-8

require 'factory_girl'
require 'faker'
require 'ostruct'

FactoryGirl.define do

  factory :testing_configs, class: OpenStruct do
    skip_create
    transient do
      user 'user_name'
      pass '222222'
      location 'http://localhost:8080'
      project 'set_project'
      output 'fetching_from_crucible.csv'
      rb_url 'http://reviewboard.lab:7777'
      git_ssh_path 'git@bitbucket.org:groovej/trash-project-for-analytics.git'
      sonar_ip 'http://localhost:9000'
    end

    initialize_with { new(username: "#{user}",
                          password: "#{pass}",
                          URL: "#{location}",
                          project: "#{project}",
                          output: "#{output}",
                          rb_url: "#{rb_url}",
                          git_ssh_path: "#{git_ssh_path}",
                          sonar_ip: "#{sonar_ip}"
                          )
    }
  end

  factory :my_response, class: OpenStruct

  factory :perforce_configs, class: OpenStruct do
    skip_create
    transient do
      p4_user 'user'
      p4_pass 'pass'
      p4_ssh_path 'ssl:groovejbogdan-2323.cloud.perforce.com:1666'
    end

    initialize_with { new(p4_user: "#{p4_user}",
                          p4_pass: "#{p4_pass}",
                          p4_ssh_path: "#{p4_ssh_path}") }
  end

  factory :all_commits_git, class: Array do
    initialize_with { [
    '2b0a63a347fd442e73885c897fe82c82e1f266bb',
    'ac47e41577e1f1776af2769b48f09d05b7f33e53',
    '5386b08a2ec684f6812ff223c350f41d6c203685',
    '6351d269492b799e55fb5a0fae454a4f3d2a5625',
    '247b0f600595a2f28a88ce3acd89fb940f8e8f8e'] }
  end

  factory :item_for_sonar, class: Hash do
    id 2
    key "org.codehaus.sonar:example-web-sonar-runner"
    name "Web project analyzed with the SonarQube Runner"
    scoper "PRJ"
    qualifier "TRK"
    date "2014-11-14T19:14:04+0200"
    creationDate "2014-11-14T14:27:25+0200"
    lname "Web project analyzed with the SonarQube Runner"
    version "1.0"
    description "er"
    msr [{'key'=>"ncloc", "val"=>35.0, "frmt_val"=>"35"},
          {'key'=>'duplicated_lines', 'val'=>0.0, 'frmt_val'=>'0'},
          {'key'=>'blocker_violations', 'val'=>0.0, 'frmt_val'=>'0'},
          {'key'=>'critical_violations', 'val'=>0.0, "frmt_val"=>"0"},
          {"key"=>"major_violations", "val"=>1.0, "frmt_val"=>"1"}]

    initialize_with{attributes.stringify_keys}
  end

  factory :jira_incoming_params, class: OpenStruct do
    skip_create
    transient do
      jira_username Faker::Internet.user_name('Nancy')
      jira_pass 'some_pass'
      url_addres Faker::Internet.url('example.com', '')
      jira_project 'wert'
      sprint_start_date '2010/09/20'
      sprint_end_date  '2014/12/10'
    end

    initialize_with { new(username: "#{jira_username}",
                          password: "#{jira_pass}",
                          URL: "#{url_addres}",
                          project: "#{jira_project}",
                          sprint_start_date: "#{sprint_start_date}",
                          sprint_end_date: "#{sprint_end_date}",
                          employees: [Faker::Internet.user_name('Nancy'), Faker::Internet.user_name('Pete')],
                          statuses: ['open', 'close'],
                          priorities: ['hight'],
                          issue_types: ['Defect', 'Bug'],
                          jira_dept_def_size: false
          ) }
  end

  factory :svn_inc_params, class: OpenStruct do
    initialize_with { new(
        from: '15th oct 1994',
        to: '5th may 2011',
        users: false,
        type: ['xml'],
        branch: 'ret',
        filename: 'executing',
        startRev: 2,
        endRev: 100,
        URL: Faker::Internet.url('localhost', ''),
        username: Faker::Internet.user_name('Noemy'),
        password: Faker::Internet.password(8)
    ) }
  end

  factory :jira_inc_params, class: OpenStruct do
    initialize_with { new(
        URL: 'https://jira.softserveinc.com',
        username: 'bogdan',
        password: 'cool_password',
        project: 'AEOA',
        sprint_start_date: '2010/09/20',
        sprint_end_date: '2014/12/10',
        def_dept_size: 'true',
        employees: %w(bogdan roman),
        statuses: %w(open closed)
    ) }
  end

end