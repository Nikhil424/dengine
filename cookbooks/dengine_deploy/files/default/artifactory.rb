require 'artifactory'
include Artifactory::Resource

   Artifactory.configure do |config|
   config.endpoint = 'http://ec2-34-212-158-175.us-west-2.compute.amazonaws.com:8081/artifactory/'
   config.username = 'admin'
   config.password = 'password'
   end

   artifact = Artifact.search(name: 'gameoflife-web-2.0-23.war').first
   artifact.download('/root')
