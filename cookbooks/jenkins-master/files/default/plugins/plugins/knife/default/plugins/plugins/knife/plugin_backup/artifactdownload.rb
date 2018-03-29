require 'chef/knife'
require 'artifactory'

class Chef
  class Knife
    class ArtifactDownload < Knife

      include Artifactory::Resource

      banner 'knife artifact download '

      def run

        Artifactory.configure do |config|
        config.endpoint = 'http://ec2-34-212-158-175.us-west-2.compute.amazonaws.com:8081/artifactory/'
        config.username = 'admin'
        config.password = 'password'
        end

        artifact = Artifact.search(name: 'gameoflife-web-1.0-20170622.073522-1.war').first
        artifact.download('/home/ubuntu')

      end
    end
  end
end
