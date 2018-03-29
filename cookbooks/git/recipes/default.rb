#
# Cookbook Name:: git
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
case node['platform_family']
  when 'debian'
    apt_update 'update' do
      action :periodic
    end

    apt_package 'git-core' do
      action :install
    end

  when 'rhel'
    yum_package 'update' do
      action :periodic
    end

    yum_package 'git-core' do
      action :install
    end

  when 'redhat'
    yum_package 'update' do
      action :periodic
    end

    yum_package 'git-core' do
      action :install
    end
end

