#------------------php CI job creation-----------------------------
php = File.join(Chef::Config[:file_cache_path], 'php-config.xml')

slave_nodes = search(:node, "role:jfrog")
if slave_nodes.empty?
  artifact_ip = '127.0.0.1'
else
  artifact_ip = slave_nodes.first["cloud_v2"]["public_ipv4"]
end

template '/var/chef/cache/php-config.xml' do
  action :create
  source 'php-config.erb'
  owner 'jenkins'
  group 'jenkins'
  mode '0644'
  variables({
    :artifactory => artifact_ip
  })
end

jenkins_job 'php-build' do
  config php
end
#------------------------------------------------------------------
#----------------------artifactory global configuration------------

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
#-------------------------------------------------------------------
#-----------------master slave setup for php build------------------
build_nodes = search(:node, "role:phing")
if build_nodes.empty?
  build_ip = '127.0.0.1'
else
  build_ip = build_nodes.first["cloud"]["public_ipv4"]
end

jenkins_ssh_slave 'php-build-machine' do
  description 'build-machine'
  remote_fs   '/home/ubuntu/jenkins-slave'
  labels      ['phing-machine', 'php-build-machine']

  # SSH specific attributes
  host        "#{build_ip}"
  user        'ubuntu'
  credentials 'ubuntu'
  launch_timeout   30
  ssh_retries      5
  ssh_wait_retries 60
end

jenkins_ssh_slave 'php-build-machine' do
  action [:create, :connect, :online]
end
#-----------------------------------------------------------------
