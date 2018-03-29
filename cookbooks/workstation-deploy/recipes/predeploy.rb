#
# Cookbook Name:: workstation-deploy
# Recipe:: predeploy
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

directory '/var/deploy' do
  owner 'root'
  group 'root'
  action :create
end

directory '/root/.ssh' do
  owner 'root'
  group 'root'
  mode  '0700'
  recursive true
end

cookbook_file '/root/.ssh/git-ssh' do
  source 'git-ssh'
  owner 'root'
  mode '0600'
end

cookbook_file '/var/deploy/wrap-ssh4git.sh' do
  source 'wrap-ssh4git.sh'
  owner 'root'
  mode '0755'
end
