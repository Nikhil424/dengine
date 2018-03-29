#
# Cookbook Name:: maven
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

apt_update 'update' do
  action :periodic
end

apt_package 'git-core' do
  action :install
end

#execute "sudo apt-get install -y openjdk-7-jdk" do
#  user "root"
#end

apt_package 'maven' do
  action :install
end

cookbook_file '/root/.bash_profile' do
  source '.bash_profile'
  mode '0644'
end

#directory '/home/ubuntu/jenkins-slave' do
#  owner 'ubuntu'
#  group 'ubuntu'
#  action :create
#end

#%w[ /home/ubuntu/jenkins-slave /home/ubuntu/jenkins-slave/workspace /home/ubuntu/jenkins-slave/workspace/maven-build].each do |path|
#  directory path do
#  owner 'ubuntu'
#  group 'ubuntu'
#  mode  '0777'
#  end
#end

#include_recipe 'tomcat::default'
