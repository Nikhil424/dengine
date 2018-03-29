#
# Cookbook Name:: dengine_deploy
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

#include_recipe 'dengine_deploy::artifactory'

class Chef::Recipe
  include ArtifactDownload
end

Chef::Log.info("The environment of the node is : #{node.chef_environment}")
download_artifact

cookbook_file '/root/artifactory.rb' do
  source 'artifactory.rb'
  action :create
end

#deploy_code 'code_deployment' do
#  action :deploy
#end
