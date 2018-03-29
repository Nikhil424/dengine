require 'chef/knife'
require 'fog/azurerm'
require 'azure_mgmt_compute'
require 'azure_mgmt_network'
require 'azure_mgmt_resources'
require 'azure_mgmt_storage'
require 'aws-sdk'

module Engine
  module DengineClientBase

    include Azure::ARM::Compute
    include Azure::ARM::Compute::Models
    include Azure::ARM::Network
    include Azure::ARM::Network::Models
    include Azure::ARM::Resources
    include Azure::ARM::Resources::Models
    include Azure::ARM::Storage
    include Azure::ARM::Storage::Models

    def self.included(includer)
      includer.class_eval do

#----------------The client initiation for AZURE-------------------------------

      def azure_compute_client

        @azure_compute_client ||= begin
            token_provider = MsRestAzure::ApplicationTokenProvider.new(Chef::Config[:knife][:azure_tenant_id], Chef::Config[:knife][:azure_client_id], Chef::Config[:knife][:azure_client_secret])
            credentials = MsRest::TokenCredentials.new(token_provider)
            azure_compute_client = ComputeManagementClient.new(credentials)
        end
        @azure_compute_client.subscription_id = Chef::Config[:knife][:azure_subscription_id]
        @azure_compute_client
      end

      def azure_network_client

        @azure_network_client ||= begin
            token_provider = MsRestAzure::ApplicationTokenProvider.new(Chef::Config[:knife][:azure_tenant_id], Chef::Config[:knife][:azure_client_id], Chef::Config[:knife][:azure_client_secret])
            credentials = MsRest::TokenCredentials.new(token_provider)
            azure_network_client = NetworkManagementClient.new(credentials)
        end
        @azure_network_client.subscription_id = Chef::Config[:knife][:azure_subscription_id]
        @azure_network_client  
      end

      def azure_resource_client

        @azure_resource_client ||= begin
            token_provider = MsRestAzure::ApplicationTokenProvider.new(Chef::Config[:knife][:azure_tenant_id], Chef::Config[:knife][:azure_client_id], Chef::Config[:knife][:azure_client_secret])
            credentials = MsRest::TokenCredentials.new(token_provider)
            azure_resource_client = Azure::ARM::Resources::ResourceManagementClient.new(credentials)
        end
        @azure_resource_client.subscription_id = Chef::Config[:knife][:azure_subscription_id]
        @azure_resource_client
      end

      def azure_storage_client

        @azure_storage_client ||= begin
            token_provider = MsRestAzure::ApplicationTokenProvider.new(Chef::Config[:knife][:azure_tenant_id], Chef::Config[:knife][:azure_client_id], Chef::Config[:knife][:azure_client_secret])
            credentials = MsRest::TokenCredentials.new(token_provider)
            azure_storage_client = Azure::ARM::Storage::StorageManagementClient.new(credentials)
        end
        @azure_storage_client.subscription_id = Chef::Config[:knife][:azure_subscription_id]
        @azure_storage_client
      end

      def azure_network_service

        @azure_network_service ||= begin
            azure_network_service = Fog::Network::AzureRM.new(
                                     tenant_id: (Chef::Config[:knife][:azure_tenant_id]), 
                                     client_id: (Chef::Config[:knife][:azure_client_id]), 
                                     client_secret: (Chef::Config[:knife][:azure_client_secret]), 
                                     subscription_id: (Chef::Config[:knife][:azure_subscription_id]), 
                                     :environment => 'AzureCloud')
        end
        @azure_network_service
      end

#---------------------Client initiation for AWS-------------------------

      def aws_connection_client
        @aws_connection_client ||= begin
          aws_connection_client = Aws::EC2::Client.new(
                 region: Chef::Config[:knife][:region],
                 credentials: Aws::Credentials.new(Chef::Config[:knife][:aws_access_key_id], Chef::Config[:knife][:aws_secret_access_key]))
        end
      end

      def aws_connection_resource
        aws_connection_resource ||= begin
          Aws.config.update({credentials: Aws::Credentials.new(Chef::Config[:knife][:aws_access_key_id], Chef::Config[:knife][:aws_secret_access_key])})
        aws_connection_resource = Aws::EC2::Resource.new(region: Chef::Config[:knife][:region])
        end
      end

      def aws_connection_elb
        @aws_connection_elb ||= begin
          aws_connection_elb = Aws::ElasticLoadBalancing::Client.new(
                 region: Chef::Config[:knife][:region],
                 credentials: Aws::Credentials.new(Chef::Config[:knife][:aws_access_key_id], Chef::Config[:knife][:aws_secret_access_key]))
            end
      end

      def aws_connection_elb2
        @aws_connection_elb2 ||= begin
          aws_connection_elb2 = Aws::ElasticLoadBalancingV2::Client.new(
                 region: Chef::Config[:knife][:region],
                 credentials: Aws::Credentials.new(Chef::Config[:knife][:aws_access_key_id], Chef::Config[:knife][:aws_secret_access_key]))
          end
      end

      def aws_autoscaling_client
        @aws_autoscaling_client ||= begin
          aws_autoscaling_client = Aws::AutoScaling::Client.new(
                 region: Chef::Config[:knife][:region],
                 credentials: Aws::Credentials.new(Chef::Config[:knife][:aws_access_key_id], Chef::Config[:knife][:aws_secret_access_key]))
        end
      end

      def aws_pricing_list
        @aws_pricing_list ||= begin
          aws_pricing_list = Aws::Pricing::Client.new(
                 region: Chef::Config[:knife][:region],
                 credentials: Aws::Credentials.new(Chef::Config[:knife][:aws_access_key_id], Chef::Config[:knife][:aws_secret_access_key]))
        end
      end

#------------------------------Client initiation for GOOGLE------------------------


      def google_connection_api
        return @google_connection_api unless @google_connection_api.nil?

        @google_connection_api = Google::Apis::ComputeV1::ComputeService.new
        @google_connection_api.google_api_authorization = google_api_authorization
        @google_connection_api.client_options = Google::Apis::ClientOptions.new.tap do |opts|
          opts.application_name    = "knife-google"
          opts.application_version = Knife::Google::VERSION
        end

        @google_connection_api
      end

      def google_api_authorization
        @google_api_authorization ||= Google::Auth.get_application_default(
          [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/compute"
          ]
        )
      end

#------------------------------------------------------------------------------------------
    end
  end
end
end
