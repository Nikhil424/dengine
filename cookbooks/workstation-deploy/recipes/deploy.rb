#
# Cookbook Name:: workstation-deploy
# Recipe:: deploy
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

class Chef::Recipe
   include PostDeploy
end

include_recipe 'workstation-deploy::predeploy'

deploy_dengine_ui 'code_deployment' do
  action :deploy
end

work_post_deploy
