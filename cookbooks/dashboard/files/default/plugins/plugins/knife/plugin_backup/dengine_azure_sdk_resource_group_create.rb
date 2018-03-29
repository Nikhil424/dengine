require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/dengine_azure_sdk_resource_base"

module Engine
    class DengineAzureSdkResourceGroupCreate < Chef::Knife

    include DengineAzureSdkResourceBase

    banner "knife dengine azure sdk resource group create (options)"

    option :name,
      :short => '-n RESOURCE_GROUP_NAME',
      :long => '--resource-group-name RESOURCE_GROUP_NAME',
      :description => "The name of the resource group that has to be created"

      def run
      name = config[:name]
        params = Azure::ARM::Resources::Models::ResourceGroup.new
	params.location = 'CentralIndia'
	promise = client.resource_groups.create_or_update("#{name}", params, custom_headers = nil)
      end
    end
end
