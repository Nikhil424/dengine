require "#{File.dirname(__FILE__)}/base/dengine_azurerm_base"

# These two are needed for the '--purge' deletion case
require 'chef/node'
require 'chef/api_client'

class Chef
  class Knife
    class DengineAzureServerDelete < Knife

      include Knife::DengineAzurermBase

      banner "knife dengine azure server delete SERVER [SERVER] (options)"

      option :purge,
        :short => "-P",
        :long => "--purge",
        :boolean => true,
        :default => false,
        :description => "Destroy corresponding node and client on the Chef Server, in addition to destroying the Windows Azure node itself.  Assumes node and client have the same name as the server (if not, add the '--node-name' option)."

      option :chef_node_name,
        :short => "-N NAME",
        :long => "--node-name NAME",
        :description => "The name of the node and client to delete, if it differs from the server name. Only has meaning when used with the '--purge' option."

      
	  # Extracted from Chef::Knife.delete_object, because it has a
      # confirmation step built in... By specifying the '--purge'
      # flag (and also explicitly confirming the server destruction!)
      # the user is already making their intent known.  It is not
      # necessary to make them confirm two more times.

      def destroy_item(klass, name, type_name)
        begin
          object = klass.load(name)
          object.destroy
          ui.warn("Deleted #{type_name} #{name}")
        rescue Net::HTTPServerException
          ui.warn("Could not find a #{type_name} named #{name} to delete!")
        end
      end

      def run
        begin
          $stdout.sync = true
          validate_arm_keys!(:azure_resource_group_name)

          vm_name = @name_args[0]
          resource_group_name = locate_config_value(:azure_resource_group_name)

          service.delete_server(locate_config_value(:azure_resource_group_name), vm_name)
          service.delete_networkinterface(locate_config_value(:azure_resource_group_name), vm_name)
          service.delete_public_ip(locate_config_value(:azure_resource_group_name), vm_name)          

          if config[:purge]
            node_to_delete = config[:chef_node_name] || vm_name
            if node_to_delete
              destroy_item(Chef::Node, node_to_delete, 'node')
              destroy_item(Chef::ApiClient, node_to_delete, 'client')
            else
              ui.warn("Node name to purge not provided. Corresponding client node will remain on Chef Server.")
            end
          else
            ui.warn("Corresponding node and client for the #{vm_name} server were not deleted and remain registered with the Chef Server")
          end
        rescue => error
          service.common_arm_rescue_block(error)
        end
      end
    end
  end
end
