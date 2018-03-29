#
# Cookbook Name:: dengine
# Recipe:: artifact
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

class Chef::Recipe
   include DeployArtifact
   include PostDeploy
end

art_version  = node['dengine']['artifact']['version']
app_name     = node['dengine']['artifact']['name']
roll_version = node['dengine']['artifact']['roll_version']

arti_deploy(app_name,art_version)
post_deploy_act(app_name,art_version,roll_version)

node.set['dengine']['artifact']['deployment'] = false
