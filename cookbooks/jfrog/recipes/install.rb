#
# Cookbook Name:: jfrog
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
class Chef::Recipe
   include SetArtiPath
end

create_path("#{node['artifact']['jfrog']['install_path']}")
path = node['artifact']['jfrog']['install_path']
version = node['artifact']['jfrog']['version']

download_artifact(path,version)

extract_artifact(path,version) if !(Dir.exist?("#{path}/artifactory/artifactory-oss-#{version}"))

copy_artifactory(path,version) if !(File.exists?("#{path}/artifactory/artifactory-oss-#{version}/tomcat/webapps/artifactory.war"))

install_artifactory(path,version) if !(File.exists?("#{path}/artifactory/artifactory-oss-#{version}/run/artifactory.pid"))

arti_path = setpath("#{node['artifact']['jfrog']['install_path']}")

  template '/etc/opt/jfrog/artifactory/default' do
    action :create
    source 'default.erb'
    user 'root'
    mode '0644'
    variables({
      :artifactory => node['java']['java_home'],
      :arti_path => arti_path
    })
  end

start_service(path,version) if !(File.exists?("#{path}/artifactory/artifactory-oss-#{version}/run/artifactory.pid"))
