# custom resource
resource_name :repository_startservice

action :install do

  execute 'install_artifact' do
    command 'sudo /root/artifactory-oss-4.7.7/bin/./installService.sh'
    cwd '/root/'
    user 'root'
  end

  template '/etc/opt/jfrog/artifactory/default' do
    action :create
    source 'default.erb'
    user 'root'
    mode '0644'
    variables({
      :artifactory => node['java']['java_home']
    })
  end

  execute 'start_artifact' do
    command 'sudo /root/artifactory-oss-4.7.7/tomcat/bin/./startup.sh'
    cwd '/root/'
    user 'root'
  end

  execute 'sudo service artifactory start' do
    command 'sudo service artifactory start'
    user 'root'
  end

end
