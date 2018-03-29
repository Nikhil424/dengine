#
# Cookbook:: jenkins-job
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

provision = File.join(Chef::Config[:file_cache_path], 'provision-config.xml')
maven = File.join(Chef::Config[:file_cache_path], 'maven-config.xml')
chef = File.join(Chef::Config[:file_cache_path], 'chef-config.xml')
dengine = File.join(Chef::Config[:file_cache_path], 'dengine-deploy.xml')
sonar = File.join(Chef::Config[:file_cache_path], 'sonar-job.xml')

#-----------------------Automating the Maven build job in Jenkins----------------------------

slave_nodes = search(:node, "role:jfrog")
if slave_nodes.empty?
  artifact_ip = '127.0.0.1'
else
  artifact_ip = slave_nodes.first["cloud_v2"]["public_ipv4"]
end

template '/var/chef/cache/maven-config.xml' do
  action :create
  source 'maven-config.erb'
  owner 'jenkins'
  group 'jenkins'
  mode '0644'
  variables({
    :artifactory => artifact_ip
  })
end

jenkins_job 'maven-build' do
  config maven
end

#----------------------Automating the server-provisioning job in jenkins---------------------

cookbook_file '/var/chef/cache/provision-config.xml' do
  source 'provision-config.xml'
  mode '0644'
end

jenkins_job 'provision-machine' do
  config provision
end

#---------------------------------Test job creation-------------------------------------------

cookbook_file '/var/chef/cache/chef-config.xml' do
  source 'chef-config.xml'
  mode '0644'
end

jenkins_job 'update-build-in-chef' do
  config chef
end

#-----------------------soanr-job------------------------------------

cookbook_file '/var/chef/cache/sonar-job.xml' do
  source 'sonar-job.xml'
  mode '0644'
end

jenkins_job 'sonar-job' do
  config sonar
end

#----------------------------dengine-deploy---------------------------------

cookbook_file '/var/chef/cache/dengine-deploy.xml' do
  source 'dengine-deploy.xml'
  mode '0644'
end

jenkins_job 'dengine-deploy' do
  config dengine
end

