class Chef::Recipe
   include FetchCredential
end

apt_package 'build-essential' do
  action :install
end

%w[ /root/.jenkins /root/.jenkins/plugins ].each do |path|
  directory path do
  owner 'root'
  group 'root'
  end
end

dot_chef 'preparing directories for .chef' do
  action :create
end

gem_install 'installing required gem for custom plugin to work' do
  action :install
end

#---------------------preconfiguring jobs for dashboard-machine-----------------------

resource = File.join(Chef::Config[:file_cache_path], 'resource-create.xml')
network = File.join(Chef::Config[:file_cache_path], 'dengine-network.xml')
dashboard = File.join(Chef::Config[:file_cache_path], 'dashboard-config.xml')
promote = File.join(Chef::Config[:file_cache_path], 'promote-job.xml')
dengineui = File.join(Chef::Config[:file_cache_path], 'dengineui-deploy.xml')
openstack = File.join(Chef::Config[:file_cache_path], 'openstack-config.xml')
server = File.join(Chef::Config[:file_cache_path], 'server-create.xml')
validate = File.join(Chef::Config[:file_cache_path], 'validate_iac.xml')
environment = File.join(Chef::Config[:file_cache_path], 'environment-config.xml')

#plugins = {
#  'build-name-setter' => 'http://mirrors.jenkins-ci.org/plugins/git/3.0.0/git.hpi',
#  'git'               => 'http://mirrors.jenkins-ci.org/plugins/build-name-setter/1.6.5/build-name-setter.hpi',
#  'credentials'       => 'http://mirrors.jenkins-ci.org/plugins/credentials/2.1.14/credentials.hpi',
#  'bitbucket'         => 'http://mirrors.jenkins-ci.org/plugins/bitbucket/1.1.5/bitbucket.hpi'
#}

plugins = {
  'build-name-setter' => '1.6.5',
  'git'               => '3.0.0',
  'credentials'       => '2.1.14',
  'bitbucket'         => '1.1.5',
}

files = {
  'resource'   => 'resource-create.xml',
  'network'    => 'dengine-network.xml',
  'dashboard'  => 'dashboard-config.xml',
  'promote'    => 'promote-job.xml',
  'dengineui'  => 'dengineui-deploy.xml',
  'openstack'  => 'openstack-config.xml',
  'server'     => 'server-create.xml',
  'validate'   => 'validate_iac.xml',
  'environment'=> 'environment-config.xml'
}

jobs = {
  'dengine-network'       => network,
  'kickstart-dashboard'   => dashboard,
  'promote-job'           => promote,
  'dengineui-deploy'      => dengineui,
  'openstack-provision'   => openstack,
  'Resource-Create-Azure' => resource,
  'server-create'         => server,
  'validate_iac'          => validate,
  'environment-create'    => environment,
}

cookbook_file "#{node['jenkins']['master']['home']}/jenkins.model.DownloadSettings.xml" do
  source 'jenkins.model.DownloadSettings.xml'
  mode '0644'
end

#plugins.each_with_index do |(plugin_name, plugin_source), index|
#  jenkins_plugin plugin_name do
#    source plugin_source
#    install_deps true
#    action :install
#    notifies :restart, 'runit_service[jenkins]', :immediately
#  end
#end

plugins.each_with_index do |(plugin_name, plugin_version), index|
  jenkins_plugin plugin_name do
    version plugin_version
    install_deps true
    action :install
#    notifies :restart, 'runit_service[jenkins]', :immediately
  end
end

files.each_with_index do |(config_name, file_name), index|
  cookbook_file "/var/chef/cache/#{file_name}" do
    source file_name
    mode '0644'
  end
end

jobs.each_with_index do |(job_name, config_name), index|
  jenkins_job job_name do
    config config_name
  end
end

#----------Creation of credentials for bitbucket integration with jenkins----------------

cred = fetch_cred

jenkins_password_credentials "#{cred.first}" do
  id          "bitbucket_credentials"
  description "This credentials is used by jenkins "
  password    "#{cred.last}"
end

#---------------------setting environment path for google--------------------------------

#execute "export GOOGLE_APPLICATION_CREDENTIALS=/var/lib/jenkins/chef-repo/.chef/Project-ce1019e73f90.json" do
#  user "jenkins"
#  cwd '/var/lib/jenkins'
#  environment({'GOOGLE_APPLICATION_CREDENTIALS' => '/var/lib/jenkins/chef-repo/.chef/Project-ce1019e73f90.json'})
#end

directory '/etc/profile.d' do
  mode '0755'
end

template '/etc/profile.d/gcp.sh' do
  source 'gcp.sh.erb'
  mode '0755'
end

ruby_block 'Set GOOGLE_APPLICATION_CREDENTIALS in /etc/environment' do
  block do
    file = Chef::Util::FileEdit.new('/etc/environment')
    file.insert_line_if_no_match(/^GOOGLE_APPLICATION_CREDENTIALS=/, "GOOGLE_APPLICATION_CREDENTIALS=#{node['workstation']['gcp']['app_credential_file']}")
    file.search_file_replace_line(/^GOOGLE_APPLICATION_CREDENTIALS=/, "GOOGLE_APPLICATION_CREDENTIALS=#{node['workstation']['gcp']['app_credential_file']}")
    file.write_file
  end
end

#---------------------------------------------------------------------------------------

jenkins_command 'safe-restart'

include_recipe 'dengine_users::default'
