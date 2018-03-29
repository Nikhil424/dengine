%w[ /root/.jenkins /root/.jenkins/plugins ].each do |path|
  directory path do
  owner 'root'
  group 'root'
  end
end

#jenkins_plugin 'artifactory' do
  # source 'https://updates.jenkins.io/download/plugins/artifactory/2.10.3/artifactory.hpi'
#  version '2.6.0'
#  install_deps true
#  action :install
#  notifies :restart, 'runit_service[jenkins]', :immediately
#end

#jenkins_plugin 'artifactory' do
#  action :enable
#  notifies :restart, 'runit_service[jenkins]', :immediately
#end

jenkins_plugin 'build-name-setter' do
  version '1.6.5'
  install_deps true
  action :install
  notifies :restart, 'runit_service[jenkins]', :immediately
end

jenkins_plugin 'git' do
  # source 'https://updates.jenkins.io/download/plugins/artifactory/2.10.3/artifactory.hpi'
  version '3.0.0'
  install_deps true
  action :install
  notifies :restart, 'runit_service[jenkins]', :immediately
end

jenkins_plugin 'parameterized-trigger' do
  version '2.34'
  install_deps true
  action :install
  notifies :restart, 'runit_service[jenkins]', :immediately
end

#jenkins_plugin 'sonar' do
 # version '2.4'
 # install_deps true
 # action :install
 # notifies :restart, 'runit_service[jenkins]', :immediately
#end
