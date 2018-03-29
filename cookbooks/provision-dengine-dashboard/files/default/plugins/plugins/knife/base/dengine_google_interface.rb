require 'chef/knife'
require "#{File.dirname(__FILE__)}/dengine_client_base"

module Engine
  class DengineGoogleInterface < Chef::Knife

    include DengineClientBase
    deps do
      require 'chef/knife/cloud/bootstrapper'
      Chef::Knife::Cloud::Bootstrapper.load_deps
      require 'chef/knife/google_server_create'
      Chef::Knife::Cloud::GoogleServerCreate.load_deps
    end

#---------------------------creating server---------------------------

    def server_create(node_name,runlist,env,network,image,ssh_user,ssh_key_name,identify_file,flavor,chef_env,gateway_key,zone,boot_disk)

puts "#{network}"
      create = Chef::Knife::Cloud::GoogleServerCreate.new

      create.config[:machine_type]          = flavor
      create.config[:image]                 = image
      create.config[:network]               = network
      create.config[:chef_node_name]        = node_name
      create.config[:ssh_user]              = ssh_user
      create.config[:ssh_port]              = 22
      create.config[:ssh_key_name]          = ssh_key_name
      create.config[:identity_file]         = identify_file
      create.config[:run_list]              = runlist
#      create.config[:subnet]                = env
      create.config[:ssh_gateway_identity]  = gateway_key
      create.config[:environment]           = chef_env
      create.config[:host_key_verify]       = false
      create.config[:gce_zone]              = zone
      create.config[:boot_disk_size]        = boot_disk
      create.name_args                      = ["#{node_name}"]
      # this has to be made dynamic
      create.config[:image_os_type]         = "linux"
      create.config[:bootstrap_protocol]    = "ssh"
      create.config[:metadata]              = []
      create.config[:additional_disks]      = []
      create.config[:server_create_timeout] = 600
#      create.config[:delete_server_on_failure] = true
      create.config[:request_refresh_rate]  = 2
      create.config[:request_timeout]       = 600
      create.config[:public_ip]             = "EPHEMERAL"

      value = create.run

      puts "NODE-NAME: #{node_name}"
      puts "ENV      :#{chef_env}"
      puts "-------------------------"

      return node_name
    end

  end
end
