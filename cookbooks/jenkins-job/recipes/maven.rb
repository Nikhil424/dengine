
#-----------------master slave setup for php build------------------
build_nodes = search(:node, "role:maven")
if build_nodes.empty?
  build_ip = '127.0.0.1'
else
  build_ip = build_nodes.first["cloud"]["public_ipv4"]
end

Chef::Log.info("the build ip #{build_ip}")
jenkins_ssh_slave 'maven-build-machine' do
  description 'maven-build-machine'
  remote_fs   '/home/ubuntu/jenkins-slave'
  labels      ['maven-machine', 'maven-build-machine']
  # SSH specific attributes
  host        "#{build_ip}"
  user        'ubuntu'
  credentials 'ubuntu'
  launch_timeout   30
  ssh_retries      5
  ssh_wait_retries 60
end

jenkins_ssh_slave 'maven-build-machine' do
  action [:create, :connect, :online]
end
#---------------------------------------------------------------------

#---------------------------maven CI job creation----------------------------------
provision = File.join(Chef::Config[:file_cache_path], 'provision-config.xml')
maven = File.join(Chef::Config[:file_cache_path], 'maven-config.xml')
chef = File.join(Chef::Config[:file_cache_path], 'chef-config.xml')
dengine = File.join(Chef::Config[:file_cache_path], 'dengine-deploy.xml')
sonar = File.join(Chef::Config[:file_cache_path], 'sonar-job.xml')

slave_nodes = search(:node, "role:jfrog")
if slave_nodes.empty?
  artifact_ip = '127.0.0.1'
else
  artifact_ip = slave_nodes.first["cloud"]["public_ipv4"]
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

files = {
  'provision'  => 'provision-config.xml',
  'chef'       => 'chef-config.xml',
  'dengine'    => 'dengine-deploy.xml'
}

files.each_with_index do |(job_name, job_file), index|
  cookbook_file "/var/chef/cache/#{job_file}" do
    source job_file
    mode '0644'
  end
end

jobs = {
  provision  => 'provision-machine',
  maven      => 'maven-build',
  chef       => 'update-build-in-chef',
  dengine    => 'dengine-deploy'
}

jobs.each_with_index do |(job_file, job_name), index|
  jenkins_job job_name do
    config job_file
  end
end
#-------------------------------------------------------------------------

#----------------------global configuration for maven job----------------
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

cookbook_file '/var/lib/jenkins/hudson.tasks.Maven.xml' do
  source 'hudson.tasks.Maven.xml'
  owner 'jenkins'
  group 'jenkins'
end
#-------------------------------------------------------------------

jenkins_command 'safe-restart' do
  action :execute
end
