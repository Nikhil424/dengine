include_recipe 'jenkins::master'

apt_package 'build-essential' do
  action :install
end

directory_create 'preparing directories for .chef' do
  action :create
end

gem_install 'installing required gem for custom plugin to work' do
  action :install
end

execute 'setting path for google' do
  command 'export GOOGLE_APPLICATION_CREDENTIALS=/var/lib/jenkin/chef-repo/.chef/Project-ce1019e73f90.json'
end

resource = File.join(Chef::Config[:file_cache_path], 'resource-create.xml')
network = File.join(Chef::Config[:file_cache_path], 'dengine-network.xml')
dashBoard = File.join(Chef::Config[:file_cache_path], 'dashboard-config.xml')
promote = File.join(Chef::Config[:file_cache_path], 'promote-job.xml')
openstack = File.join(Chef::Config[:file_cache_path], 'openstack-config.xml')
server = File.join(Chef::Config[:file_cache_path], 'server-create.xml')

cookbook_file '/var/chef/cache/resource-create.xml' do
  source 'resource-create.xml'
  mode '0644'
end

cookbook_file '/var/chef/cache/dengine-network.xml' do
  source 'dengine-network.xml'
  mode '0644'
end

cookbook_file '/var/chef/cache/dashboard-config.xml' do
  source 'dashboard-config.xml'
  mode '0644'
end

cookbook_file '/var/chef/cache/promote-job.xml' do
  source 'promote-job.xml'
  mode '0644'
end

cookbook_file '/var/chef/cache/openstack-config.xml' do
  source 'openstack-config.xml'
  mode '0644'
end

cookbook_file '/var/chef/cache/server-create.xml' do
  source 'server-create.xml'
  mode '0644'
end

jenkins_job 'Resource-Create-Azure' do
  config resource
end

jenkins_job 'dengine-network' do
  config network
end

jenkins_job 'kickstart-dashboard' do
  config dashBoard
end

jenkins_job 'promote-job' do
  config promote
end

jenkins_job 'openstack-provision' do
  config openstack
end

jenkins_job 'server-create' do
  config server
end

include_recipe 'dengine_users::default'
