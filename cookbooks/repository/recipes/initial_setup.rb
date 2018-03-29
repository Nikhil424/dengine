include_recipe 'unzip::default'

remote_file '/root/jfrog-artifactory-oss-4.7.7.zip' do
  source 'https://bintray.com/jfrog/artifactory/download_file?file_path=jfrog-artifactory-oss-4.7.7.zip'
  action :create_if_missing
  user 'root'
  mode '0644'
end

execute 'extract_jfrog_artifactory' do
  command 'sudo unzip jfrog-artifactory-oss-4.7.7.zip'
  cwd '/root'
  user 'root'
  not_if { Dir.exist?('/root/artifactory-oss-4.7.7') }
end

remote_file 'Copy artifactory file' do
  path '/root/artifactory-oss-4.7.7/tomcat/webapps/artifactory.war'
  source 'file:////root/artifactory-oss-4.7.7/webapps/artifactory.war'
  owner 'root'
  not_if { File.exists?('/root/artifactory-oss-4.7.7/tomcat/webapps/artifactory.war') }
end

include_recipe 'repository::config_start'
