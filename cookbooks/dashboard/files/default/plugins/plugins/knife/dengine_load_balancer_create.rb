require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/dengine_azure_interface"
require "#{File.dirname(__FILE__)}/base/dengine_aws_interface"
require "#{File.dirname(__FILE__)}/base/dengine_data_tresure"

module Engine
  class DengineLoadBalancerCreate < Chef::Knife

    include DengineDataTresure

    banner 'knife dengine load balancer create (options)'

      option :listener_protocol,
        :long => '--listener-protocol HTTP',
        :description => 'Listener protocol (available: HTTP, HTTPS, TCP, SSL) (default HTTP)',
        :default => 'HTTP'

      option :listener_instance_protocol,
        :long => '--listener-instance-protocol HTTP',
        :description => 'Instance connection protocol (available: HTTP, HTTPS, TCP, SSL) (default HTTP)',
        :default => 'HTTP'

      option :listener_lb_port,
        :long => '--listener-lb-port 80',
        :description => 'Listener load balancer port (default 80)',
        :default => 80

      option :listener_instance_port,
        :long => '--listener-instance-port 80',
        :description => 'Instance port to forward traffic to (default 80)',
        :default => 80

      option :ssl_certificate_id,
        :long => '--ssl-certificate-id SSL-ID',
        :description => 'ARN of the server SSL certificate'

      option :cloud,
        :long => '--cloud CLOUD_PROVIDER_NAME',
        :description => "The name of the cloud provider for ex: aws, azure, google, openstack etc"

      option :type,
        :short => '-t ELB_TYPE',
        :long => '--type ELB_TYPE',
        :description => "The type of the load balancer that has to be created possible values are: network, application"

      option :app,
        :short => '-a APP_NAME',
        :long => '--app APP_NAME',
        :description => "The name of the application for which the environment is being setup",
        :default => "java"

      option :name,
        :short => '-n ELB_NAME',
        :long => '--name ELB_NAME',
        :description => "The name of the elastic load balancer that has to be created"

      option :network,
        :long => '--network NETWORK_NAME',
        :description => "The name of the network in which elastic load balancer has to be created"

      option :ping_path,
        :short => '-p PING_PATH',
        :long => '--ping_path PING_PATH',
        :description => "The ping path to configure the health check for the classic loadbalancers. It looks something like: HTTP:80/index.html"

      option :resource_group,
        :short => '-r RESOURCE_GROUP_NAME',
        :long => '--resource-group-name RESOURCE_GROUP_NAME',
        :description => "The name of Resource group in which the network that has to be created",
        :default => "Dengine"

    def run

      if config[:cloud] == "aws"
        @client = DengineAwsInterface.new
      elsif config[:cloud] == "azure"
        @client = DengineAzureInterface.new
      elsif config[:cloud] == "google"
        puts "#{ui.color('we are in alfa, soon we will be here', :cyan)}"
        exit
        @client = ''
      elsif config[:cloud] == "openstack"
        puts "#{ui.color('we are in alfa, soon we will be here', :cyan)}"
        exit
        @client = ''
	  elsif (config[:cloud].nil?)
        Chef::Log.error "You have misspell the word or you might have not chose the cloud provider "
        exit
      end

      # validating data bag
      data_bag_find = check_resource_existence("loadbalancers","#{config[:cloud]}-#{config[:type]}-#{config[:name]}")
      if data_bag_find == 0
        create_lb
      else
        puts "#{ui.color('loadbalancer already exists please check', :cyan)}"
      end

      return "#{config[:cloud]}-#{config[:type]}-#{config[:name]}"
 
    end

#------------------------creation of lb------------------------------
    def create_lb

      if config[:cloud] == "aws"

        subnet = fetch_data("networks","#{config[:network]}","SUBNET-ID")
        vpc = fetch_data("networks","#{config[:network]}","VPC-ID")
        sg_group = fetch_data("networks","#{config[:network]}","SECURITY-ID")
        subnet_id1 = subnet.first
        subnet_id2 = subnet[1]
        security_group = ["#{sg_group}"]        

        if (config[:type] == "application") || (config[:type] == "appli")
          create_aws_application_lb(subnet_id1,subnet_id2,security_group,vpc)
        elsif config[:type] == "network"
          create_aws_classic_lb(subnet_id1,subnet_id2,security_group,vpc)
	    elsif (config[:cloud].nil?)
          Chef::Log.error "You have misspell the word or you might have not chose the cloud provider "
          exit
        end

      elsif config[:cloud] == "azure"

        resource_group = config[:resource_group]
        name = "#{config[:cloud]}-#{config[:type]}-#{config[:name]}"
        if (config[:type] == "application") || (config[:type] == "appli")
          puts "#{ui.color('we are in alfa, soon we will be here', :cyan)}"
          exit
        elsif config[:type] == "network"
          create_azure_classic_lb(resource_group,name)
	    elsif (config[:cloud].nil?)
          Chef::Log.error "You have misspell the word or you might have not chose the cloud provider "
          exit
        end

      elsif config[:cloud] == "google"
      elsif config[:cloud] == "openstack"
      elsif (config[:cloud].nil?)
        exit
      end
    end
#-----------------------lb creation for aws---------------------------------
    def create_aws_application_lb(subnet_id1,subnet_id2,security_group,vpc)

      # creation of load balancer
      puts "#{ui.color('creating load balancer for the environment', :cyan)}"
      elb_details = @client.create_application_loadbalancer("#{config[:cloud]}-#{config[:type]}-#{config[:name]}",subnet_id1,subnet_id2,security_group)
      elb_dns = elb_details.first
      elb_arn = elb_details.last
      puts "#{ui.color('load balancer created', :cyan)}"
      puts ""

      # creation of target group
      puts "#{ui.color('creating target group for the load balancer created', :cyan)}"
      elb_target_arn = @client.create_target_group("#{config[:cloud]}-#{config[:type]}-#{config[:name]}","#{config[:listener_protocol]}","#{config[:listener_lb_port]}",vpc)
      puts "#{ui.color('target group created', :cyan)}"
      puts ""

      # creation of listeners
      puts "#{ui.color('creating listeners for the load balancer created', :cyan)}"
      lb_listeners = @client.create_application_listeners(elb_arn,"#{config[:listener_protocol]}","#{config[:listener_lb_port]}",elb_target_arn)
      puts "#{ui.color('listeners created', :cyan)}"
      puts ""

      # creating and adding data to data_bag
      store_lb_data(elb_dns,elb_target_arn,elb_arn)

      # printing details of the loadbalancers
      puts ''
      puts "========================================================="
      puts "#{ui.color('lb-name', :magenta)}          : #{config[:cloud]}-#{config[:type]}-#{config[:name]}"
      puts "#{ui.color('lb-dns', :magenta)}           : #{elb_dns}"
      puts "#{ui.color('lb-arn', :magenta)}           : #{elb_arn}"
      puts "#{ui.color('lb-target-arn', :magenta)}    : #{elb_target_arn}"
      puts "========================================================="
      puts ''

      return elb_dns
    end

    def create_aws_classic_lb(subnet_id1,subnet_id2,security_group,vpc)

      # creation of load balancer
      puts "#{ui.color('creating load balancer for the environment', :cyan)}"
      elb_details = @client.create_classic_loadbalancer("#{config[:cloud]}-#{config[:type]}-#{config[:name]}",subnet_id1,subnet_id2,security_group,"#{config[:listener_protocol]}","#{config[:listener_lb_port]}",vpc,"#{config[:listener_instance_protocol]}","#{config[:listener_instance_port]}")
      elb_dns = elb_details
      puts "#{ui.color('load balancer created', :cyan)}"
      puts ""
      puts "#{ui.color('creating health checks for the load balancer created', :cyan)}"
      puts "."

      #  creation of health check
      lb_health_checks = @client.create_health_check("#{config[:cloud]}-#{config[:type]}-#{config[:name]}","#{config[:ping_path]}")
      puts "."
      puts "#{ui.color('Health check created successfully', :cyan)}"
      puts ""

      # creating and adding data to data_bag
      store_lb_data(elb_dns,"","")

      # printing details of the loadbalancers
      puts ''
      puts "========================================================="
      puts "#{ui.color('lb-name', :magenta)}          : #{config[:cloud]}-#{config[:type]}-#{config[:name]}"
      puts "#{ui.color('lb-dns', :magenta)}           : #{elb_dns}"
      puts "========================================================="
      puts ''

      return elb_dns
    end

#-----------------------lb creation for azure---------------------------------

    def create_azure_classic_lb(resource_group,name)
      @client.create_availability_set(resource_group,name)
      elb_dns = @client.create_lb(resource_group,name)
      store_lb_data(elb_dns,"","")
    end

#-----------------------storing loadbalancers details---------------------
    def store_lb_data(elb_dns,elb_target_arn,elb_arn)

      if Chef::DataBag.list.key?("loadbalancers")
        puts ''
        puts "#{ui.color('Found databag for this', :cyan)}"
        puts "#{ui.color('Writing data in to the data bag item', :cyan)}"
        puts ''

        if config[:cloud] == "aws"
          data = {
                 'id' => "#{config[:cloud]}-#{config[:type]}-#{config[:name]}",
                 'CLOUD' => "#{config[:cloud]}",
                 'APP-NAME' => "#{config[:app]}",
                 'ELB-NAME' => "#{config[:cloud]}-#{config[:type]}-#{config[:name]}",
                 'ELB_DNS' => "#{elb_dns}",
                 'TARGET-GROUP-ARN' => ["#{elb_target_arn}"],
                 'ELB_ARN' => "#{elb_arn}"                
                 }
        elsif config[:cloud] == "azure"
          data = {
                 'id' => "#{config[:cloud]}-#{config[:type]}-#{config[:name]}",
                 'CLOUD' => "#{config[:cloud]}",
                 'ALB-NAME' => "#{config[:cloud]}-#{config[:type]}-#{config[:name]}",
                 'ALB-DNS' => "#{elb_dns}",
                 'ALB-BACK-END-POOL' => "#{config[:cloud]}-#{config[:type]}-#{config[:name]}-vm-pool",
                 'ALB-NAT-RULES' => ["nat1","nat2","nat3"],
                 'ALB-AVAILABILITY-SET' => "#{config[:cloud]}-#{config[:type]}-#{config[:name]}-availability-set"
                 }
        elsif config[:cloud] == "google"
        elsif config[:cloud] == "openstack"
        elsif config[:cloud] == "azure"
        end
        
        dengine_item = Chef::DataBagItem.new
        dengine_item.data_bag("loadbalancers")
        dengine_item.raw_data = data
        dengine_item.save

        puts "#{ui.color('Data has been written in to databag successfully', :cyan)}"
      else
        puts ''
        puts "#{ui.color('Was not able to find databag for this', :cyan)}"
        puts "#{ui.color('Hence creating databag', :cyan)}"
        puts ''
        users = Chef::DataBag.new
        users.name("loadbalancers")
        users.create

        if config[:cloud] == "aws"
          data = {
                 'id' => "#{config[:cloud]}-#{config[:type]}-#{config[:name]}",
                 'CLOUD' => "#{config[:cloud]}",
                 'APP-NAME' => "#{config[:app]}",
                 'ELB-NAME' => "#{config[:cloud]}-#{config[:type]}-#{config[:name]}",
                 'ELB_DNS' => "#{elb_dns}",
                 'TARGET-GROUP-ARN' => ["#{elb_target_arn}"],
                 'ELB_ARN' => "#{elb_arn}"                
                 }
        elsif config[:cloud] == "azure"
          data = {
                 'id' => "#{config[:cloud]}-#{config[:type]}-#{config[:name]}",
                 'CLOUD' => "#{config[:cloud]}",
                 'ALB-NAME' => "#{config[:cloud]}-#{config[:type]}-#{config[:name]}",
                 'ALB-DNS' => "#{elb_dns}",
                 'ALB-BACK-END-POOL' => "#{config[:cloud]}-#{config[:type]}-#{config[:name]}-vm-pool",
                 'ALB-NAT-RULES' => ["nat1","nat2","nat3"],
                 'ALB-AVAILABILITY-SET' => "#{config[:cloud]}-#{config[:type]}-#{config[:name]}-availability-set"
                 }
        elsif config[:cloud] == "google"
        elsif config[:cloud] == "openstack"
        elsif config[:cloud] == "azure"
        end

        databag_item = Chef::DataBagItem.new
        databag_item.data_bag("loadbalancers")
        databag_item.raw_data = data
        databag_item.save
      end
    end

  end
end
