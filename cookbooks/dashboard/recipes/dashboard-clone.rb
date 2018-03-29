#
# Cookbook Name:: dashboard
# Recipe:: dashboard-clone
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

%w[ /root/.ssh /var/deploy/ ].each do |path|
  directory path do
  owner 'root'
  group 'root'
  mode  '0700'
  recursive true
  end
end

cookbook_file '/root/.ssh/git-ssh' do
  source '/deploy/git-ssh'
  owner 'root'
  mode '0600'
end

cookbook_file '/var/deploy/wrap-ssh4git.sh' do
  source '/deploy/wrap-ssh4git.sh'
  owner 'root'
  mode '0755'
end

chef_repo 'preparing chef-repo' do
  action :create
end

#dot_chef 'preparing directories for .chef' do
#  action :create
#end
