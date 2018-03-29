require 'chef/knife'
require "#{File.dirname(__FILE__)}/dengine_network_base"

module Engine
  class DengineNetworkCreate < Chef::Knife

    include DengineNetworkBase
    include DengineClientBase
    include DengineResourceBase

    banner 'knife dengine network create (options)'

    option :name,
      :short => '-n NETWORK_NAME',
      :long => '--name NETWORK_NAME',
      :description => "The name of the network that has to be created"

    def run

      name = config[:name]

      # validating data_bag
      data_bag_find = check_data_bag(name)
      #puts data_bag_find

        if data_bag_find == 1
          create_network(name)
        else
          puts "#{ui.color('Network already exists please check', :cyan)}"
        end

    end

    def create_network(name)

#------------ CIDR details----------------------------------
      vpc_cidr = '192.168.0.0/16'
      sub_cidr1 = '192.168.10.0/24'
      sub1_name = "#{name}_sub1"
      sub_cidr2 = '192.168.20.0/24'
      sub2_name = "#{name}_sub2"

#------------ creation of VPC--------------------------------
      puts "#{ui.color('creating vpc for the environment', :cyan)}"
      ec2_vpc = create_vpc(name,vpc_cidr)

#------------  creation of Subnet----------------------------
      puts "#{ui.color('creating subnet for the environment', :cyan)}"
      ec2_subnet1 = create_subnet(sub_cidr1,ec2_vpc,sub1_name,"us-west-2a")
      ec2_subnet2 = create_subnet(sub_cidr2,ec2_vpc,sub2_name,"us-west-2b")

#------------ creation of IGW--------------------------------
      puts "#{ui.color('creating Internet Gateway for the environment', :cyan)}"
      ec2_igw = create_igw(name,ec2_vpc)

#------------ creation of Route Table-------------------------
      puts "#{ui.color('creating Route Table for the environment', :cyan)}"
      ec2_route1 = create_route_table(ec2_vpc,name,ec2_igw,ec2_subnet1)
      ec2_route2 = create_route_table(ec2_vpc,name,ec2_igw,ec2_subnet2)

#------------ creation of Security Group---------------------- 
      puts "#{ui.color('creating Security group for the environment', :cyan)}"
      ec2_security = create_security_group(name,ec2_vpc)

#------------------- creating and adding data to data_bag-------------------------
      if Chef::DataBag.list.key?("network")
        puts ''
        puts "#{ui.color('Found databag for this', :cyan)}"
        puts "#{ui.color('Writing data in to the data bag item', :cyan)}"
        puts ''

        data = {
               'id' => "#{name}",
               'VPC-ID' => "#{ec2_vpc}",
               'SUBNET-ID' => ["#{ec2_subnet1}","#{ec2_subnet2}"],
               'SECURITY-ID' => "#{ec2_security}"
               }
        dengine_item = Chef::DataBagItem.new
        dengine_item.data_bag("network")
        dengine_item.raw_data = data
        dengine_item.save

        puts "#{ui.color('Data has been written in to databag successfully', :cyan)}"
      else
        puts ''
        puts "#{ui.color('Was not able to fine databag for this', :cyan)}"
        puts "#{ui.color('Hence creating databag', :cyan)}"
        puts ''
        users = Chef::DataBag.new
        users.name("network")
        users.create
        data = {
               'id' => "#{name}",
               'VPC-ID' => "#{ec2_vpc}",
               'SUBNET-ID' => ["#{ec2_subnet1}","#{ec2_subnet2}"],
               'SECURITY-ID' => "#{ec2_security}"
               }
        databag_item = Chef::DataBagItem.new
        databag_item.data_bag("network")
        databag_item.raw_data = data
        databag_item.save
      end

#----------------------- printing resource details------------------------------
      puts ''
      puts "========================================================="
      puts "#{ui.color('vpc-id', :magenta)}           : #{ec2_vpc}"
      puts "#{ui.color('subnet-ids', :magenta)}       : #{ec2_subnet1},#{ec2_subnet2}"
      puts "#{ui.color('igw-id', :magenta)}           : #{ec2_igw}"
      puts "#{ui.color('security-group-id', :magenta)}: #{ec2_security}"
      puts "========================================================="
      puts ''

    end

  end
end
