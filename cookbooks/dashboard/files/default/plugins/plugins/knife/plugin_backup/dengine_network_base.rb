require 'chef/knife'
require "#{File.dirname(__FILE__)}/dengine_client_base"
require "#{File.dirname(__FILE__)}/dengine_resource_base"

module Engine
  module DengineNetworkBase

    def self.included(includer)
      includer.class_eval do
        deps do
          require 'chef/search/query'
        end
      end
    end

    def create_vpc(name,vpc_cidr)
      puts "#{ui.color('VPC creation has been started', :cyan)}"
      puts ''
      vpc = connection_resource.create_vpc({ cidr_block: vpc_cidr })
      vpc_id = "#{vpc.vpc_id}"
      vpc.create_tags({ tags: [{ key: 'Name', value: "#{name}" }]})
      puts "#{ui.color('VPC creation in progress', :cyan)}"
      puts ''

      vpc.wait_until(max_attempts:10, delay:6) {|vpc| vpc.state == 'available' }
      puts "#{ui.color('VPC is created', :cyan)}"
      puts ''
      return vpc_id
    end

    def create_subnet(cidr,vpc_id,name,zone)
      puts "#{ui.color('subnet creation has been started', :cyan)}"
      subnet = connection_resource.create_subnet({vpc_id: vpc_id, cidr_block: cidr, availability_zone: zone})
      subnet.create_tags({ tags: [{ key: 'Name', value: "#{name}" }]})
      subnet_id = subnet.id
      puts "."
      puts "."
      puts "#{ui.color('SUBNET creation in progress', :cyan)}"
      puts ''

      subnet.wait_until(max_attempts:10, delay:6) {|subnet| subnet.state == 'available' }
      puts "#{ui.color('SUBNET is created', :cyan)}"
      puts ''
      return subnet_id
    end

    def create_igw(subnet_name,vpc_id)
      igw = connection_resource.create_internet_gateway
      igw.create_tags({ tags: [{ key: 'Name', value: "#{subnet_name}" }]})
      igw.attach_to_vpc(vpc_id: vpc_id)
      gate_way_id = igw.id
      puts "."
      puts "."
      puts "#{ui.color('IGW creation is complete', :cyan)}"
      puts ''

      return gate_way_id
    end

    def create_route_table(vpc_id,subnet_name,internet_gateway,subnet)
      puts "#{ui.color('creating route table for the VPC', :cyan)}"
      puts "."
      table = connection_resource.create_route_table({ vpc_id: vpc_id})
      route_table_id = table.id
      table.create_tags({ tags: [{ key: 'Name', value: "#{subnet_name}" }]})
      # Chef::Log.debug 'Creating public route'
      puts "#{ui.color('Writing routes for the route table', :cyan)}"
      table.create_route({ destination_cidr_block: '0.0.0.0/0', gateway_id: internet_gateway })
      # Chef::Log.debug 'Associating route table with subnet'
      puts "."
      puts "#{ui.color('Attaching route table to the subnet', :cyan)}"
      table.associate_with_subnet({ subnet_id: subnet })
      puts ''

    end

    def create_security_group(name,vpc_id)
      security_group = connection_client.create_security_group({
      dry_run: false,
        group_name: name,
        description: "security-group used by VPC #{name}",
        vpc_id: vpc_id
      })
      security_id = security_group.group_id
      connection_client.authorize_security_group_ingress({dry_run: false, group_id: "#{security_id}", ip_protocol: "tcp", from_port: 0, to_port: 65535, cidr_ip: "0.0.0.0/0"})

      return security_id
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
