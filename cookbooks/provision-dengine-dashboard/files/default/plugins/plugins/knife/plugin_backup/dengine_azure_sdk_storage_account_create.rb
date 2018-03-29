require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/dengine_azure_sdk_storage_base"


module Engine
  class DengineAzureSdkStorageAccountCreate < Chef::Knife

    include DengineAzureSdkStorageBase

    banner "knife dengine azure sdk storage account create (options)"

      def run
        time = Time.new
        params = Azure::ARM::Storage::Models::StorageAccountCreateParameters.new
        params.location = 'CentralIndia'
        sku = Models::Sku.new
        sku.name = 'Standard_LRS'
        params.sku = sku
        params.kind = Models::Kind::Storage
        puts "Creating Storage Account #{time.hour}:#{time.min}:#{time.sec}"
        promise = storage_client.storage_accounts.create('Dengine', 'dengine', params)
        t = Time.new
        puts "Created Storage Account #{t.hour}:#{t.min}:#{t.sec}"
      end

    end
   end

