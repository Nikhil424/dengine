require 'aws-sdk'
require 'chef/knife'

module Engine
  module DengineResourceBase

    def self.included(includer)
      includer.class_eval do

        def connection_resource
          connection_resource ||= begin
            Aws.config.update({credentials: Aws::Credentials.new(Chef::Config[:knife][:aws_access_key_id], Chef::Config[:knife][:aws_secret_access_key])})
          connection_resource = Aws::EC2::Resource.new(region: 'us-west-2')

          end
        end
      end
    end
  end
end

