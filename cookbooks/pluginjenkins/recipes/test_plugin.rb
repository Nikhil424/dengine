%w[ /root/.jenkins /root/.jenkins/plugins ].each do |path|
  directory path do
  owner 'root'
  group 'root'
  end
end

plugins = {
  'git'                    => '3.0.0',
  'artifactory'            => '2.6.0',
  'build-name-setter'      => '1.6.5',
  'parameterized-trigger'  => '2.34',
  'sonar'                  => '2.4'
}

plugins.each_with_index do |(plugin_name, plugin_version), index|
  jenkins_plugin plugin_name do
    version plugin_version
    install_deps true
    action :install
    notifies :restart, 'runit_service[jenkins]', :immediately
  end
end
