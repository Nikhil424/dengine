
# Cookbook Name:: unzip
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

case node['platform_family']
  when 'debian'
    apt_package 'unzip' do
      action :install
    end
  when 'rhel'
   yum_package 'unzip' do
     action :install
   end
  when 'redhat'
   yum_package 'unzip' do
     action :install
   end
end

