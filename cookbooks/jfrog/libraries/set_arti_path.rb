require 'chef/dsl'
require 'chef/knife'

module SetArtiPath

  def setpath(path)

    "#{path}/artifactory"

  end

  def create_path(path)

    dir = Chef::Resource::Directory.new("#{path}/artifactory", run_context)
    dir.recursive(true)
    dir.mode(0644)
    dir.owner('root')
    dir.group('root')
    dir.run_action(:create)

  end

  def download_artifact(path,version)

    rem_file = Chef::Resource::RemoteFile.new("#{path}/artifactory.zip", run_context)
    rem_file.source("https://bintray.com/jfrog/artifactory/download_file?file_path=jfrog-artifactory-oss-#{version}.zip")
    rem_file.mode(0644)
    rem_file.user('root')
    rem_file.run_action(:create_if_missing)
  
  end

  def extract_artifact(path,version)

    extrt = Chef::Resource::Execute.new("sudo unzip artifactory.zip -d #{path}/artifactory", run_context)
    extrt.cwd("#{path}")
    extrt.user('root')
    extrt.run_action(:run)

  end

  def copy_artifactory(path,version)

    rem_file = Chef::Resource::RemoteFile.new("#{path}/artifactory/artifactory-oss-#{version}/tomcat/webapps/artifactory.war", run_context)
    rem_file.path("#{path}/artifactory/tomcat/webapps/artifactory.war")
    rem_file.source("file:////#{path}/artifactory/artifactory-oss-#{version}/webapps/artifactory.war")
    rem_file.owner('root')

  end

  def install_artifactory(path,version)

    install = Chef::Resource::Execute.new("sudo #{path}/artifactory/artifactory-oss-#{version}/bin/./installService.sh", run_context)
    install.cwd("#{path}")
    install.user('root')
    install.run_action(:run)

  end

  def start_service(path,version)

    start_artifactory(path,version)
    bring_up_artifactory(path,version)

  end

  def start_artifactory(path,version)

    start = Chef::Resource::Execute.new("sudo #{path}/artifactory/artifactory-oss-#{version}/tomcat/bin/./startup.sh", run_context)
    start.cwd("#{path}")
    start.user('root')
    start.run_action(:run)

  end

  def bring_up_artifactory(path,version)

    bring = Chef::Resource::Execute.new("sudo service artifactory start", run_context)
    bring.cwd("#{path}")
    bring.user('root')
    bring.run_action(:run)

  end

end
