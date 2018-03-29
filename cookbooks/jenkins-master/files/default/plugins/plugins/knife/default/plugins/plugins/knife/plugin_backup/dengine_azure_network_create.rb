require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/dengine_azure_network_base"

module Engine
  class DengineAzureNetworkCreate < Chef::Knife

    include DengineAzureNetworkBase
    include DengineAzureSdkNetworkBase
    include DengineAzureFogNetworkBase
	

      banner 'knife dengine azure network create (options)'
	
      option :name,
      :short => '-n NETWORK_NAME',
      :long => '--name NETWORK_NAME',
      :description => "The name of the network that has to be created"
	  
      option :resource_group,
      :short => '-r RESOURCE_GROUP_NAME',
      :long => '--resource-group-name RESOURCE_GROUP_NAME',
      :description => "The name of Resource group in which the network that has to be created"	
  
    def run
      name = config[:name]
      resource_group = config[:resource_group]
        # validating data_bag
      data_bag_find = check_data_bag(name)
      puts data_bag_find

        if data_bag_find == 1
          create_network(name)
        else
          puts "#{ui.color('Network already exists please check', :cyan)}"
        end    
    end
	
    def create_network(name)

# CIDR details
      vpn_cidr = '192.168.0.0/16'
      sub_cidr1 = '192.168.10.0/24'
      sub1_name = "#{name}_sub1"
      sub_cidr2 = '192.168.20.0/24'
      sub2_name = "#{name}_sub2"
      resource_group = config[:resource_group]
# creation of Security Group
      puts "#{ui.color('Creating Security group for the environment', :cyan)}"
      azure_nsg1 = create_security_group("#{name}_nsg1", resource_group)
      azure_nsg2 = create_security_group("#{name}_nsg2", resource_group)
		
# creation of Security Rule for Nsg
      puts "#{ui.color('Creating Security group for the environment', :cyan)}"
      security_rule1 = create_security_rule_for_nsg("#{name}_nsg_rule", "#{name}_nsg1", sub_cidr1, resource_group)
      security_rule2 = create_security_rule_for_nsg("#{name}_nsg_rule", "#{name}_nsg2", sub_cidr2, resource_group)

# creation of VPN
      puts "#{ui.color('Creating vpc for the environment', :cyan)}"
      azure_vpn = create_vpn(resource_group, "#{name}_vpn", vpn_cidr)

# creation of Route Table
      puts "#{ui.color('Creating Route Tables for the environment', :cyan)}"
      puts " "
      azure_route_table1 = create_route_table("#{name}_route_table1", sub_cidr1, resource_group)
      puts "#{ui.color('Created Route Table 1 for the environment', :cyan)}"
      puts " "
      azure_route_table2 = create_route_table("#{name}_route_table2", sub_cidr2, resource_group)
      puts "#{ui.color('Created Route Table 2 for the environment', :cyan)}"
      puts " "

# creation of Subnet
      puts "#{ui.color('creating subnet for the environment', :cyan)}"	  
      azure_sub1 = create_subnet(sub1_name,sub_cidr1, "#{name}_vpn", "#{name}_nsg1", "#{name}_route_table1", resource_group)
      azure_sub2 = create_subnet(sub2_name,sub_cidr2, "#{name}_vpn", "#{name}_nsg2", "#{name}_route_table2", resource_group)

# creating and adding data to data_bag
      users = Chef::DataBag.new
      users.name("#{name}")
      users.create
      data = {
             'id' => "#{name}",
             'VPN-ID' => "#{name}_vpn",
             'SUBNET-ID' => ['sub1,sub2'],
             'SECURITY-ID' => ["#{name}_nsg1","#{name}_nsg2"],
             'ROUTE-ID' => ["#{name}_route_table1","#{name}_route_table2"]
             }
      databag_item = Chef::DataBagItem.new
      databag_item.data_bag("#{name}")
      databag_item.raw_data = data
      databag_item.save

      # printing resource details
      puts ''
      puts "========================================================="
      puts "#{ui.color('vpn-id', :magenta)}          	: #{azure_vpn}"
      puts "#{ui.color('subnet-ids', :magenta)}       	: #{azure_sub1},#{azure_sub2}"
      puts "#{ui.color('security-group-id', :magenta)}  : #{azure_nsg1},#{azure_nsg2}"
      puts "#{ui.color('route-table-id', :magenta)}	: #{azure_route_table1},#{azure_route_table2}"
      puts "========================================================="
      puts ''

      end
  end
end

