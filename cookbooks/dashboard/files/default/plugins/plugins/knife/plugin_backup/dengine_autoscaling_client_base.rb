require 'aws-sdk'
require 'chef/knife'

module  Engine
  module DengineAutoscalingClientBase

    def self.included(includer)
      includer.class_eval do

        def connection_client
          @connection_client ||= begin
            connection_client = Aws::EC2::Client.new(
                   region: 'us-west-2',
                   credentials: Aws::Credentials.new(Chef::Config[:knife][:aws_access_key_id], Chef::Config[:knife][:aws_secret_access_key]))
          end

        end
        def autoscaling_client
          @autoscaling_client ||= begin
            autoscaling_client = Aws::AutoScaling::Client.new(
                   region: 'us-west-2',
                   credentials: Aws::Credentials.new(Chef::Config[:knife][:aws_access_key_id], Chef::Config[:knife][:aws_secret_access_key]))
          end
        end
      end
    end
  end
end 
