#
# Cookbook Name:: dengine
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

class Chef::Recipe
   include AttributeNode
end
#chek_node_existence

include_recipe 'dengine::directory'

if node['dengine']['artifact']['deployment'] == "true"
  include_recipe "dengine::artifact"
end
