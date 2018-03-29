#
# Cookbook Name:: jenkinsuser
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

jenkinsuser_test 'This is to remove initial setup wizard in jenkins' do
  action :remove
end

