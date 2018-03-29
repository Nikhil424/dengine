require 'chef/knife'
require "#{File.dirname(__FILE__)}/dengine_azure_sdk_network_base"
require "#{File.dirname(__FILE__)}/dengine_azure_fog_network_base"

module Engine
  module DengineAzureNetworkBase

    include DengineAzureSdkNetworkBase
    include DengineAzureFogNetworkBase

# Creation of NSG
  
    def create_security_group(name, resource_group)
        params = NetworkSecurityGroup.new

        params.location = "CentralIndia"

        promise = client.network_security_groups.create_or_update("#{resource_group}", "#{name}", params)

        puts "name = #{promise.name}"
	puts " " 
        puts "id = #{promise.id}"
    end
	
# Creation of VPN	
	
	def create_vpn(resource_group, name, vpn_cidr)
        params = VirtualNetwork.new

        address_space = AddressSpace.new
        address_space.address_prefixes = ["#{vpn_cidr}"]
        params.address_space = address_space

        params.location = 'CentralIndia'

        puts "#{ui.color('VPN creation has been started', :cyan)}"
        puts ''
        puts "#{ui.color('VPN creation in progress', :cyan)}"
        puts ''
        promise = client.virtual_networks.create_or_update("#{resource_group}", "#{name}", params)

        puts "name = #{promise.name}"
	puts " "
        puts "id = #{promise.id}"
    end


# Creation of Security Rule and adding to NSG	
	
	def create_security_rule_for_nsg(name, nsg_name, sub_cidr, resource_group)

        params = SecurityRule.new
        params.description = "AllowSSHProtocol"
        params.protocol = 'Tcp'
        params.source_port_range = '*'
        params.destination_port_range = '22'
        params.source_address_prefix = '*'
        params.destination_address_prefix = "#{sub_cidr}"
        params.access = 'Allow'
        params.priority = '100'
        params.direction = 'Inbound'
        puts " Adding security_rules to the NSG"
	puts " "
        promise = client.security_rules.create_or_update("#{resource_group}", "#{nsg_name}", "#{name}", params)
	puts " Added security_rules to the NSG"
	puts " "
		
    end
	
# Creation of ROUTE Table

    def create_route_table(name, sub_cidr, resource_group)
         params = RouteTable.new

          rou = Route.new
          rou.name = "#{name}_route"
          rou.address_prefix = "#{sub_cidr}"
          rou.next_hop_type = 'VirtualNetworkGateway'

          params.routes = [rou]

          params.location = 'CentralIndia'

          route_table = client.route_tables.create_or_update("#{resource_group}", "#{name}", params)
    end
	
# Creation of Subnets

    def create_subnet(name,cidr, vpn_name, nsg_name, route_table, resource_group)
	    subnet = service.subnets.create(
            name: "#{name}",
            resource_group: "#{resource_group}",
            virtual_network_name: "#{vpn_name}",
            address_prefix: "#{cidr}",
            network_security_group_id: "/subscriptions/#{Chef::Config[:knife][:azure_subscription_id]}/resourceGroups/#{resource_group}/providers/Microsoft.Network/networkSecurityGroups/#{nsg_name}",
            route_table_id: "/subscriptions/#{Chef::Config[:knife][:azure_subscription_id]}/resourceGroups/#{resource_group}/providers/Microsoft.Network/routeTables/#{route_table}"
                                        )
    end

    def check_data_bag(name)
        databag_item = Chef::DataBagItem.new
          if Chef::DataBag.list.key?("#{name}")
          return 0
          else
          return 1
          end
    end

	
  end
end
