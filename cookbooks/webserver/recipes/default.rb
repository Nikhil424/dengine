#
# Cookbook Name:: webserver
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
apt_update 'update' do
  action :periodic
end

apt_package 'apache2' do
  action :install
end

cookbook_file '/var/www/html/index.html' do
  source 'index.html'
  #owner 'root'
  #group 'root'
end

execute 'restarting apache' do
  command 'service apache2 restart'
  user 'root'
end
