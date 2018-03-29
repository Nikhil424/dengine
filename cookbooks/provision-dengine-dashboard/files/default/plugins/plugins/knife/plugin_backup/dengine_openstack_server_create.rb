require 'chef/knife'
require 'chef/knife/openstack_server_create'

module Engine
    class DengineOpenstackServerCreate < Chef::Knife

    deps do
      require 'chef/knife/openstack_server_create'
      Chef::Knife::OpenstackServerCreate.load_deps
    end

    banner 'knife dengine openstack server create (options)'

      option :network,
        :short => '-n ENV_NETWORK',
        :long => '--network ENV_NETWORK',
        :description => "In which network the server has to be created"

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


    def run

      flavor         = config[:flavor]
      role           = config[:role]
      chef_env       = config[:environment]

      runlist        = set_runlist(role)
      chef_role      = check_role(role)
      node_name      = set_node_name(app_name,role,chef_env,id)
      image          = Chef::Config[:knife][:ops_image]
      ssh_user       = "ubuntu"
      ssh_key_name   = Chef::Config[:knife][:ops_key]
      network        = Chef::Config[:knife][:network_ids]

      output = ops_server_create(node_name,runlist,image,ssh_user,ssh_key_name,flavor,chef_env,network)

      if role == 'tomcat'
        chek_node_existence_and_set(node_name)
      else
        puts "#{ui.color('Since I am not a part of web servers my attributes are not set to default values for web', :cyan)}"
      end
      return output

    end

    def check_role(role)
      query = Chef::Search::Query.new
      chef_role = query.search('role', "name:#{role}").first
      crap_out "No role '#{role}' found on the server" if chef_role.empty?
      chef_role.first
    end

    def set_node_name(app_name,role,chef_env,id)
      "#{app_name}-#{role}-#{chef_env}-#{id}"
    end

    def set_runlist(role)
        ["role[#{role}]"]
    end

    def ops_server_create(node_name,runlist,image,ssh_user,ssh_key_name,flavor,chef_env,network)

      ops_create = Chef::Knife::OpenstackServerCreate.new

      ops_create.config[:flavor]              = flavor
      ops_create.config[:image]               = image
      ops_create.config[:chef_node_name]      = node_name
      ops_create.config[:ssh_user]            = ssh_user
      ops_create.config[:ssh_key_name]        = ssh_key_name
      ops_create.config[:run_list]            = runlist
      ops_create.config[:environment]         = chef_env
      ops_create.config[:network_ids]         = network

      value = ops_create.run

      puts "NODE-NAME: #{node_name}"
      puts "ENV      :#{chef_env}"
      puts "-------------------------"

      return node_name
    end

  end
end
