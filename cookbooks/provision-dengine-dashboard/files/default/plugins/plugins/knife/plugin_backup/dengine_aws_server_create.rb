require 'chef/knife'
require "#{File.dirname(__FILE__)}/dengine_server_base"

module Engine
    class DengineAwsServerCreate < Chef::Knife

    include DengineServerBase

    deps do
      require 'chef/knife/ec2_server_create'
      Chef::Knife::Ec2ServerCreate.load_deps
    end

    banner 'knife dengine aws server create (options)'

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

      app_name       = config[:app]
      id             = config[:id]
      flavor         = config[:flavor]
      role           = config[:role]
      chef_env       = config[:environment]
      network        = config[:network]

      chef_role      = check_role(role)
      node_name      = set_node_name(app_name,role,chef_env,id)
      runlist        = set_runlist(role)
      sg_group       = get_security_group(network)
      env            = get_env(network)
      env            = env.first
      security_group = ["#{sg_group}"]
      image          = Chef::Config[:knife][:image]
      ssh_user       = "ubuntu"
      ssh_key_name   = Chef::Config[:knife][:ssh_key_name]
      identify_file  = Chef::Config[:knife][:identity_file]
      region         = Chef::Config[:knife][:region]

      output = aws_server_create(node_name,runlist,env,security_group,image,ssh_user,ssh_key_name,identify_file,region,flavor,chef_env)

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

    def aws_server_create(node_name,runlist,env,security_group,image,ssh_user,ssh_key_name,identify_file,region,flavor,chef_env)

      aws_create = Chef::Knife::Ec2ServerCreate.new

      aws_create.config[:flavor]              = flavor
      aws_create.config[:image]               = image
      aws_create.config[:security_group_ids]  = security_group
      aws_create.config[:chef_node_name]      = node_name
      aws_create.config[:ssh_user]            = ssh_user
      aws_create.config[:ssh_port]            = 22
      aws_create.config[:ssh_key_name]        = ssh_key_name
      aws_create.config[:identity_file]       = identify_file
      aws_create.config[:run_list]            = runlist
      aws_create.config[:subnet_id]           = env
      aws_create.config[:associate_public_ip] = true
      aws_create.config[:region]              = region
      aws_create.config[:environment]         = chef_env

      value = aws_create.run

      puts "NODE-NAME: #{node_name}"
      puts "ENV      :#{chef_env}"
      puts "-------------------------"

      return node_name
    end

  end
end
