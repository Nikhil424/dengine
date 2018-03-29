require 'aws-sdk'
require 'chef/knife'

module Engine
  module DengineElbBase

          def connection_elb
            @connection_elb ||= begin
              connection_elb = Aws::ElasticLoadBalancing::Client.new(
                     region: 'us-west-2',
                     credentials: Aws::Credentials.new(Chef::Config[:knife][:aws_access_key_id], Chef::Config[:knife][:aws_secret_access_key]))
            end
          end

          def connection2_elb
            @connection2_elb ||= begin
              connection2_elb = Aws::ElasticLoadBalancingV2::Client.new(
                     region: 'us-west-2',
                     credentials: Aws::Credentials.new(Chef::Config[:knife][:aws_access_key_id], Chef::Config[:knife][:aws_secret_access_key]))
            end
          end

  end
end
