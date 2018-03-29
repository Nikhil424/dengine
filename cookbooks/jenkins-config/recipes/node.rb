build_nodes = search(:node, "role:maven")
if build_nodes.empty?
  build_ip = '127.0.0.1'
else
  build_ip = build_nodes.first["cloud"]["public_ipv4"]
end


jenkins_ssh_slave 'build-machine' do
  description 'build-machine'
  remote_fs   '/home/ubuntu/jenkins-slave'
  labels      ['maven-machine', 'build-machine']

  # SSH specific attributes
  host        "#{build_ip}"
  user        'ubuntu'
  credentials 'ubuntu'
  launch_timeout   30
  ssh_retries      5
  ssh_wait_retries 60
end

jenkins_ssh_slave 'build-machine' do
  action [:create]
end

if build_ip == '127.0.0.1'
  Chef::Log.info("Cannot bring the slave online as I don't have valid ipaddress")
else
  jenkins_ssh_slave 'build-machine' do
    action [:connect, :online]
  end
end

jenkins_command 'safe-restart' do 
  action :execute
end
