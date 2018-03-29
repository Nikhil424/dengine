
directory_create 'preparing directories for .chef' do
  action :create
end

apt_package 'build-essential' do
  action :install
end

gem_install 'installing required gem for custom plugin to work' do
  action :install
end

include_recipe 'jenkins::master'
include_recipe 'pluginjenkins::test_plugin'
include_recipe 'jenkins-config::credentials'
include_recipe 'jenkins-job'
include_recipe 'jenkins-config'
include_recipe 'dengine_users::default'

remote_directory '/var/lib/jenkins/chef-repo/templates' do
  source 'templates'
  owner 'jenkins'
  group 'jenkins'
  files_owner 'jenkins'
  files_group 'jenkins'
  files_mode 0644
  mode 0755
end

%w[ /var/lib/jenkins/chef-repo/data_bags /var/lib/jenkins/chef-repo/data_bags/job_id ].each do |path|
  directory path do
  owner 'jenkins'
  group 'jenkins'
  end
end
