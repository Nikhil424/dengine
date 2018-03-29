#
# Cookbook Name:: cache-clear
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

execute 'clearing cache' do
  command 'echo 1 > /proc/sys/vm/drop_caches'
end
