#
# Cookbook Name:: jenkins-config
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

#-------------------automating master-slave configuration for jenkins---------------------------------------

#directory '/var/lib/jenkins/nodes/build-machine' do
#  owner 'jenkins'
#  group 'jenkins'
#  action :create
#end

directory '/home/ubuntu/jenkins-node' do
  owner 'ubuntu'
  group 'ubuntu'
  action :create
end

#cookbook_file '/root/.jenkins/chef-coe.pem' do
#  source 'chef-coe.pem'
#  owner 'jenkins'
#  group 'jenkins'
#  mode '0400'
#end

#build_nodes = search(:node, "role:maven")
#if build_nodes.empty?
#  build_ip = '127.0.0.1'
#else
#  build_ip = build_nodes.first["cloud_v2"]["public_ipv4"]
#end

#template '/var/lib/jenkins/nodes/build-machine/config.xml' do
#  action :create
#  source 'config.erb'
#  owner 'jenkins'
#  group 'jenkins'
#  mode '0644'
#  variables({
#    :slave => build_ip
#  })
#end

#---------------------------Automating Maven configuration for Jenkins---------------------------------------

cookbook_file '/var/lib/jenkins/hudson.tasks.Maven.xml' do
  source 'hudson.tasks.Maven.xml'
  owner 'jenkins'
  group 'jenkins'
end

#----------------------------Automating Jfrog configuration in Jenkins---------------------------------------

artifact_nodes = search(:node, "role:jfrog")
if artifact_nodes.empty?
  artifact_ip = '127.0.0.1'
else
  artifact_ip = artifact_nodes.first["cloud_v2"]["public_ipv4"]
end

template '/var/lib/jenkins/org.jfrog.hudson.ArtifactoryBuilder.xml' do
  action :create
  source 'org.jfrog.hudson.ArtifactoryBuilder.erb'
  owner 'jenkins'
  group 'jenkins'
  mode '0644'
  variables({
    :artifactory => artifact_ip
  })
end

#------------------------------------------------------------------------------------------------------------
include_recipe 'jenkins-config::node'

