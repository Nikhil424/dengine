require 'chef/knife'
require 'json'

module Engine
  class DengineAppDeploy < Chef::Knife

    deps do
      require 'chef/knife/ssh'
      Chef::Knife::Ssh.load_deps
    end

      banner "knife dengine app deploy (options)"

      option :app_name,
        :short => '-a APP_NAME',
        :long => '--name APP_NAME',
        :description => "The name of the application that has to be deployed"

      option :node,
        :short => '-n NODE',
        :long => '--node NODE',
        :description => "The name of the application that has to be deployed"

      option :where,
        :short => '-w ENV_NAME',
        :long => '--where ENV_NAME',
        :description => "The name of the environment where the app has to be deployed"

      option :force,
        :short => '-f FORCE_DEPLOY',
        :long => '--force FORCE_DEPLOY',
        :description => "Use this flag if you need to forcefully give the version here, else version will be fetched from respective data_bag",
        :boolean => true | false,
        :default => false

      option :version,
        :long => '--version APPLICATION_VERSION',
        :description => "The version of the appplication where it has to be deployed"

        def run

          server = config[:node]
          env = config[:where]
          prepare_node_for_deploy(env,server)
        end

        def get_nodes(name,env)

          node_query = Chef::Search::Query.new
          node_found = node_query.search('node', "role:#{name} AND chef_environment:#{env}").first

          return node_found

        end

        def prepare_node_for_deploy(env,server)

          puts "#{ui.color('Preparing the web nodes for the deployment process', :cyan)}"
          puts "."
          puts "#{ui.color('Fetching the verion of the application to be deployed', :cyan)}"
          version = get_build_verion
          puts "."
          puts "#{ui.color('The application version that will be deployed', :magenta)} :#{version}"
          node_name = get_nodes(server,env)
          node_name.each do |node|
            roll_version = node['dengine']['artifact']['version']
            node.set['dengine']['artifact']['name']          = config[:app_name]
            node.set['dengine']['artifact']['version']       = "#{version}"
            node.set['dengine']['artifact']['roll_version']  = "#{roll_version}"
            node.set['dengine']['artifact']['deployment']    = 'true'
            node.save
          puts "."
          puts "#{ui.color('Node is prepared successfully for deployment', :cyan)}"
          puts "."
          puts "#{ui.color('Running chef-client to accomplish the deployment', :cyan)}"
          run_chef_on_node(node)
          puts "#{ui.color('Deplyment process is complete', :cyan)}"
          end

        end

        def get_build_verion

        if force = config[:force] == true
          version = config[:version]
        elsif force = config[:force] == false
          data_item_sub = Chef::DataBagItem.new
          data_item_sub.data_bag("job-id")
          data_value_sub = Chef::DataBagItem.load("job-id","job-id")
          data_sub = data_value_sub.raw_data["build-job"]
          version = data_sub.last
        else

        end

        return version

        end

        def run_chef_on_node(node_name)

          ssh = Chef::Knife::Ssh.new
          ssh.ui = ui

          ssh.name_args                   = ["name:#{node_name.name}", 'sudo chef-client']
          ssh.config[:ssh_user]           = Chef::Config[:knife][:ssh_user]
          ssh.config[:ssh_port]           = Chef::Config[:knife][:ssh_port]
          ssh.config[:ssh_identity_file]  = Chef::Config[:knife][:identity_file]
#          ssh.config[:forward_agent]      = true
#          ssh.config[:host_key_verify]    = false
#          ssh.config[:manual]             = false
#          ssh.config[:ssh_timeout]        = 120
           ssh.config[:attribute]         = 'cloud.public_ips'
          ssh.config[:on_error]           = :raise
          Chef::Log.info("DEPLOY: Running chef on node: #{node_name.name}")
          ssh.run

        end

  end
end
