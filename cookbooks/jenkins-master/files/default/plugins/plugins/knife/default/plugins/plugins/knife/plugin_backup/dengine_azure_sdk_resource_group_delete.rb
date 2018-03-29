require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/dengine_azure_sdk_resource_base"

module Engine
    class DengineAzureSdkResourceGroupDelete < Chef::Knife

    include DengineAzureSdkResourceBase

    banner "knife dengine azure sdk resource group delete (options)"

    option :name,
      :short => '-n RESOURCE_GROUP_NAME',
      :long => '--resource-group-name RESOURCE_GROUP_NAME',
      :description => "The name of the resource group that has to be created"

      def run
      name = config[:name]
        ui.warn "Deleting this resource group will delete the following resources inside it."
        promise = client.resource_groups.list_resources("#{name}", filter = nil, expand = nil, top = nil, custom_headers = nil)
        promise.each do |resource|
          puts "#{resource.name} | #{resource.location}"
        end
        ui.confirm('Do you really want to delete resource group with the above resources...?')
        promise = client.resource_groups.delete("#{name}", custom_headers = nil)
        puts "The Resource group #{name} is deleted"
        puts ""
        puts "Creating a fresh Resource Group with the same name"
        params = ResourceGroup.new
        params.location = 'CentralIndia'
        promise = client.resource_groups.create_or_update("#{name}", params, custom_headers = nil)
      end
    end
end
