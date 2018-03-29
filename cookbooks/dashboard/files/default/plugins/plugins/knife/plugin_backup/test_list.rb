require 'chef/knife'

class Chef
  class Knife
    class TestList < Knife

      banner "knife test list"

    option :name,
      :short => '-n NODE_NAME',
      :long => '--name NODE_NAME',
      :description => "The name of the node that has to be altered"

    option :env,
      :short => '-e ENVIRONMENT_NAME',
      :long => '--env ENVIRONMENT_NAME',
      :description => "The name of the environment in which node exists"

      def run
        name = config[:name]
        env  = config[:env]

        update_runlist(name,env)

      end

      def get_nodes(name,env)
        node_query = Chef::Search::Query.new
        node_found = node_query.search('node', "name:#{name} AND chef_environment:#{env}").first

      return node_found
      end

      def update_runlist(server,env)
        node_name = get_nodes(server,env)

        if node_name.empty?
          puts "#{ui.color('I was unable to find the node with name', :cyan)} :#{server}"
        else
          node_name.each do |node|
            node.run_list.add("role[sensu_client]")
            node.run_list.add("role[dengine_chef]")
            node.save
          run_chef_on_node(node)
          end
        end

      end

      def run_chef_on_node(node_name)

        ssh = Chef::Knife::Ssh.new
        ssh.ui = ui

        ssh.name_args                   = ["name:#{node_name.name}", 'sudo chef-client']
        ssh.config[:ssh_user]           = Chef::Config[:knife][:ssh_user]
        ssh.config[:ssh_port]           = Chef::Config[:knife][:ssh_port]
        ssh.config[:ssh_identity_file]  = Chef::Config[:knife][:identity_file]
        ssh.config[:on_error]           = :raise
        Chef::Log.info("DEPLOY: Running chef on node: #{node_name.name}")
        ssh.run

      end
        
    end
  end
end
