require 'artifactory'

module ArtifactDownload

  include Artifactory::Resource

  def download_artifact(app_version)
    Artifactory.configure do |config|
    config.endpoint = 'http://ec2-34-212-158-175.us-west-2.compute.amazonaws.com:8081/artifactory/'
    config.username = 'admin'
    config.password = 'password'
    end

    artifact = Artifact.search(name: 'gameoflife-web-2.0-23.war').first
    artifact.download('/var/deploy/tmp')
    Chef::Log.info("The environment of the node is : #{node.chef_environment}")
  end

end
