#
# Cookbook Name:: copy-jenkins
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

%w[ /var/tmp /var/tmp/jenkins ].each do |path|
  directory path do
  owner 'root'
  group 'root'
  end
end


cookbook_file '/var/tmp/jenkins/jenkins.war' do
  source 'jenkins.war'
end
