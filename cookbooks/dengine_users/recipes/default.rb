#
# Cookbook Name:: dengine_users
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

cookbook_file '/etc/sudoers' do
  source 'sudoers'
  mode '0440'
end
