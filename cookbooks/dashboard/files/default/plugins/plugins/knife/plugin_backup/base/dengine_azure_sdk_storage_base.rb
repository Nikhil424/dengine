require 'chef/knife'
require 'azure_mgmt_storage'

module Engine
  module DengineAzureSdkStorageBase

      include Azure::ARM::Storage

      def self.included(includer)
      includer.class_eval do

        def storage_client

          @storage_client ||= begin
            token_provider = MsRestAzure::ApplicationTokenProvider.new(Chef::Config[:knife][:azure_tenant_id], Chef::Config[:knife][:azure_client_id], Chef::Config[:knife][:azure_client_secret])
            credentials = MsRest::TokenCredentials.new(token_provider)
            storage_client = Azure::ARM::Storage::StorageManagementClient.new(credentials)
          end
        @storage_client.subscription_id = Chef::Config[:knife][:azure_subscription_id]
        @storage_client
        end
        end
      end
    end
  end
