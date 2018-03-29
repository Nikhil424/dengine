#
# Cookbook:: dashboard
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.


include_recipe 'git::default'
include_recipe 'dashboard::dashboard-ui'
include_recipe 'dashboard::dashboard'
include_recipe 'dashboard::dashboard-machine'
