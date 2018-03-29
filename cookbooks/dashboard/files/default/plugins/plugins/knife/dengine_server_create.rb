require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/dengine_google_interface"
require "#{File.dirname(__FILE__)}/base/dengine_data_tresure"

module Engine
  class DengineServerCreate < Chef::Knife

    include DengineDataTresure

    deps do
      require "#{File.dirname(__FILE__)}/base/dengine_aws_interface"
      Engine::DengineAwsInterface.load_deps
      require "#{File.dirname(__FILE__)}/base/dengine_azure_interface"
      Engine::DengineAzureInterface.load_deps
    end

    banner 'knife dengine server create (options)'

      option :app,
        :short => '-a APP_NAME',
        :long => '--app_name APP_NAME',
        :description => "Name of the application for which the stack is being created."

      option :id,
        :short => '-i UNIQUE_ID',
        :long => '--id UNIQUE_ID',
        :description => "Give your server a unique ID inorder to make it different from others.",
        :default => 0

      option :network,
        :short => '-n ENV_NETWORK',
        :long => '--network ENV_NETWORK',
        :description => "In which network the server has to be created",
        :default => "default"

      option :environment,
        :short => '-e SERVER_ENV',
        :long => '--environment SERVER_ENV',
        :description => "In which Environment the server has to be created"

      option :role,
        :short => '-r CHEF_ROLE',
        :long => '--role CHEF_ROLE',
        :description => "Which chef role to use. Run 'knife role list' for a list of roles."

      option :flavor,
        :short => '-f FLAVOR',
        :long => '--flavor FLAVOR',
        :description => "The flavor of server. The hardware capacities of the machine",
        :proc => Proc.new { |f| Chef::Config[:knife][:flavor] = f }

      option :cloud,
        :long => '--cloud CLOUD_PROVIDER_NAME',
        :description => "The name of the cloud provider for ex: aws, azure, google, openstack etc"

      option :machine_user,
        :short => '-m MACHINE_USER',
        :long => '--machine-user MACHINE_USER',
        :description => "Name of the user that has to be assigned fo VM.",
        :default => "ubuntu"

      option :boot_disk_size,
        :long => "--boot-disk-size SIZE",
        :description => "Size of the persistent boot disk between 10 and 10000 GB, specified in GB; default is '10' GB, this is exclusively for GCP",
        :default => "10"

      option :resource_group,
        :long => '--resource-group-name RESOURCE_GROUP_NAME',
        :description => "The name of Resource group in which the network that has to be created",
        :default => "Dengine"

      option :lb_name,
        :long => '--lb-name LOAD_BALANCER_NAME',
        :description => "The name of the load balancer to which the vm has to be attached, this is exclusively for AZURE",
        :default => "null"

      option :storage_account,
        :long => '--storage-account STORAGE_ACCOUNT',
        :description => "The name of the storage account in which the vm has to be created, this is exclusively for AZURE",
        :default => "dengine"

    def run

      if config[:cloud] == "aws"
        @client = DengineAwsInterface.new
      elsif config[:cloud] == "azure"
        @client = DengineAzureInterface.new
      elsif config[:cloud] == "google"
        @client = DengineGoogleInterface.new
      elsif config[:cloud] == "openstack"
        puts "#{ui.color('we are in alfa, soon we will be here', :cyan)}"
        exit
        @client = ''
      elsif (config[:cloud].nil?)
        Chef::Log.error "You have misspell the word or you might have not chose the cloud provider "
        exit
      end

      name_name = server_create

      if config[:role] == 'tomcat'
        node_name = set_node_name(config[:app],config[:role],config[:environment],config[:id])
        chek_node_existence_and_set(node_name)
      else
        puts "#{ui.color('Since I am not a part of web servers my attributes are not set to default values for web', :cyan)}"
      end

      return name_name
 
    end

    def server_create

      flavor         = config[:flavor]
      chef_env       = config[:environment]
#      chef_role      = check_role("#{config[:role]}")
      node_name      = set_node_name("#{config[:app]}","#{config[:role]}","#{config[:environment]}","#{config[:id]}")
      runlist        = set_runlist("#{config[:role]}")
      ssh_user       = "#{config[:machine_user]}"
      ssh_key_name   = Chef::Config[:knife][:ssh_key_name]
      identify_file  = Chef::Config[:knife][:identity_file]
      get_subnet     = fetch_data("networks","#{config[:network]}","SUBNET-ID")
      get_vpc        = fetch_data("networks","#{config[:network]}","VPC-ID")
      gateway_key    = Chef::Config[:knife][:gateway_key]

      if config[:cloud] == "aws"

        sg_group       = fetch_data("networks","#{config[:network]}","SECURITY-ID")
        env            = get_subnet.sample(1).to_s.tr("[]", '').tr('"', '')
        security_group = ["#{sg_group}"]
        image          = Chef::Config[:knife][:image]
        region         = Chef::Config[:knife][:region]

        @client.create_server(node_name,runlist,env,security_group,image,ssh_user,ssh_key_name,identify_file,region,flavor,chef_env)
        return node_name

      elsif config[:cloud] == "azure"

        env                  = get_vpc
        subnet               = get_subnet.first
        image                = Chef::Config[:knife][:azure_image]
        resource_group       = "#{config[:resource_group]}"
        region               = Chef::Config[:knife][:azure_service_location]
        storage_account      = "#{config[:storage_account]}"
        storage_account_type = "Standard_LRS"
        ssh_pub_key          = Chef::Config[:knife][:public_key]
        security_group       = fetch_data("networks","#{config[:network]}","SECURITY-ID").first

        if config[:lb_name] == "null"
          puts "#{ui.color('I am not part of any load balancer', :cyan)}"
        else
          availability_set     = fetch_data("loadbalancers","#{config[:lb_name]}","ALB-AVAILABILITY-SET")
          lb                   = config[:lb_name]
          nat_rule             = fetch_data("loadbalancers","#{config[:lb_name]}","ALB-NAT-RULES").sample(1).to_s.tr("[]", '').tr('"', '')
          backend_pool         = fetch_data("loadbalancers","#{config[:lb_name]}","ALB-BACK-END-POOL")
         puts "this is nat rule: #{nat_rule}"
        end

        @client.create_server(resource_group,node_name,region,storage_account,storage_account_type,env,subnet,flavor,image,ssh_user,ssh_pub_key,availability_set,lb,nat_rule,chef_env,gateway_key,backend_pool,runlist,security_group)
        return node_name

      elsif config[:cloud] == "google"

        env            = ""
        boot_disk      = config[:boot_disk_size]
        network        = "default"
        image          = Chef::Config[:knife][:gce_image]
        zone           = Chef::Config[:knife][:gce_zone]

        @client.server_create(node_name,runlist,env,network,image,ssh_user,ssh_key_name,identify_file,flavor,chef_env,gateway_key,zone,boot_disk)
        return node_name

      elsif config[:cloud] == "openstack"



      elsif (config[:cloud].nil?)
        Chef::Log.error "You have misspell the word or you might have not chose the cloud provider "
        exit
      end

    end

  end
end
