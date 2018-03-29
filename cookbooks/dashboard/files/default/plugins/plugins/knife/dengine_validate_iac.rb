require 'chef/knife'
require 'json'

module Engine
  class DengineValidateIac < Chef::Knife

    deps do
      require 'chef/knife/role_from_file'
      Chef::Knife::RoleFromFile.load_deps
    end

    banner "knife dengine validate iac (options)"

    option :environments,
      :short => '-e',
      :long => '--environments',
      :boolean => true,
      :description => "Test only environment syntax"
    option :roles,
      :short => '-r',
      :long => '--roles',
      :boolean => true,
      :description => "Test only role syntax"
    option :nodes,
      :short => '-n',
      :long => '--nodes',
      :boolean => true,
      :description => "Test only node syntax"
    option :databags,
      :short => '-d',
      :long => '--databags',
      :boolean => true,
      :description => "Test only databag syntax"
    option :plugins,
      :short => '-p',
      :long => '--plugins',
      :boolean => true,
      :description => "Test only plugins syntax"
    option :cookbooks,
      :short => '-c',
      :long => '--cookbooks',
      :boolean => true,
      :description => "Test only cookbook syntax"
    option :all,
      :short => '-a',
      :long => '--all',
      :boolean => true,
      :description => "Test syntax of all roles, environments, nodes, databags and cookbooks"

    deps do
      require 'pathname'
      require 'chef/knife/cookbook_test'
      Chef::Knife::CookbookTest.load_deps
      require 'foodcritic'
      require 'foodcritic/command_line'

    end

    def run

      if config[:roles]
        role = test_object("/var/lib/jenkins/jobs/validate_iac/workspace/roles/*", "role")
      elsif config[:environments]
        environments = test_object("/var/lib/jenkins/jobs/validate_iac/workspace/environments/*", "environment")
      elsif config[:nodes]
        nodes = test_object("/var/lib/jenkins/jobs/validate_iac/workspace/nodes/*", "node")
      elsif config[:databags]
        test_databag("/var/lib/jenkins/jobs/validate_iac/workspace/data_bags/*", "data bag")
      elsif config[:cookbooks]
        cookbook = test_cookbooks()
        foodcritic   = foodcritic()
      elsif config[:plugins]
        plugins = test_plugins("/var/lib/jenkins/jobs/validate_iac/workspace/cookbooks/dashboard/files/default/plugins/**/*", "plugins")
      elsif config[:all]
        # The environment is freezed to _defalut as of now it can be changed in future if in need.
        status = last_chef_run_status('workstation','_default')
        if status == 'ran_chef_here'
          iac_state = test_all
        elsif status == 'not_necessary_running_chef_here'
          iac_state = test_all
        else
          puts "#{ui.color('Did not get a valid input from the function hence quitting', :magenta)}"
          exit
        end
      else
        ui.msg("Usage: knife dengine syntax check --help")
      end
      if iac_state.each {|i| i == 'success'}
        #upload cookbooks
        upload_cookbooks
        #upload roles
        upload_roles
        #upload nodes
#        upload_nodes
        #upload environments
        upload_environments
        #upload data_bags
#        upload_data_bags
        #running chef-client in this box
        run_chef_here
      end
    end

    # Test all cookbooks
    def test_cookbooks(path)
      ui.msg("Testing all cookbooks...")
      test_cookbook = Chef::Knife::CookbookTest.new
      test_cookbook.config[:all] = "-a"
      test_cookbook.config[:cookbook_path] = path
      test_cookbook.run
    end

    # Test object syntax
    def test_object(dirname,type)
      ui.msg("Finding type #{type} to test from #{dirname}")
      check_syntax(dirname,nil,type)
    end

    # Test plugin syntax
    def test_plugins(dirname,type)
      ui.msg("Finding type #{type} to test from #{dirname}")
      check_syntax(dirname,nil,type)
    end


    # Test databag syntax
    def test_databag(dirname, type)
      ui.msg("Finding type #{type} to test from #{dirname}")
      dirs = Dir.glob(dirname).select { |d| File.directory?(d) }
      dirs.each do |directory|
        dir = Pathname.new(directory).basename
        check_syntax("#{directory}/*", dir, type)
      end
    end

    # Test all the resources
    def test_all
      role         = test_object("/var/lib/jenkins/jobs/validate_iac/workspace/roles/*", "role")
      environments = test_object("/var/lib/jenkins/jobs/validate_iac/workspace/environments/*", "environment")
#      nodes        = test_object("/var/lib/jenkins/jobs/validate_iac/workspace/nodes/*", "node")
      data_bag     = test_databag("/var/lib/jenkins/jobs/validate_iac/workspace/data_bags/*", "data bag")
      plugins      = test_plugins("/var/lib/jenkins/jobs/validate_iac/workspace/cookbooks/dashboard/files/default/plugins/**/*", "plugins")
#     test_plugins("/root/chef-repo/*", "plugins")
#      cookbook     = test_cookbooks("/var/lib/jenkins/jobs/validate_iac/workspace/cookbooks/")
      foodcritic   = foodcritic()
      return role,environments,data_bag,plugins,cookbook,foodcritic#,nodes
    end
    # I will validatethe json and send my response
    def valid_json?(json)
      JSON.parse(json)
      return "success"
      rescue JSON::ParserError => e
      return "failure"
    end

    # Common method to test file syntax
    def check_syntax(dirpath, dir = nil, type)
      files = Dir.glob("#{dirpath}").select { |f| File.file?(f) }
      files.each do |file|
        fname = Pathname.new(file).basename
        if ("#{fname}".end_with?('.json'))
          ui.msg("Testing file #{file}")
          json = File.read(file)
          result = valid_json?(json)
          case @result
          when "failure"
            raise JsonSyntaxError.new("JSON Syntax Is not Happy", "ERROR:")
          else
          end
        elsif("#{fname}".end_with?('.rb'))
          ui.msg("Testing file #{file}")
          cmd = Mixlib::ShellOut.new("ruby -c #{file}")
          cmd.run_command
          @error_ruby = cmd.stderr
          if (!@error_ruby.empty?) && ("#{fname}".end_with?('.rb'))
            raise RubySyntaxError.new("Ruby Syntax Is not Happy", "ERROR:")
          end
        end
      end
      if !@error_ruby.nil? && @result == 'success'
        puts "."
        puts "#{ui.color('Kudos syntaxes of of both JSON Ruby files for are great....We are good to go ahead', :cyan)}"
        puts "Kudos syntaxes of Ruby files for #{type} are great....We are good to go ahead"
        puts "."
        return 'success'
      end
    end

    def foodcritic()
      ["/var/lib/jenkins/jobs/validate_iac/workspace/roles/","/var/lib/jenkins/jobs/validate_iac/workspace/cookbooks/","/var/lib/jenkins/jobs/validate_iac/workspace/environments/"].each do |path|
        puts "."
        puts "#{ui.color('I am checking the standards for ', :cyan)}#{path}"
        puts ""
        [01,02,04,05,06,07,10,13,16,19,24,25,26,27,28,29,31,32,33,34,38,39,40,41,42,43,44,45,48,49,50,51,66,74,77,82,86,88,89,92,94,95,98].each do |rule_no|
          foodcritic_check(rule_no.to_s,path)
        end
      end
    end

    def foodcritic_check(rule_no,path)
      if path.include? "roles"
        type = "-R"
      elsif path.include? "cookbooks"
        type = "-t FC0#{rule_no}"
      elsif path.include? "environments"
        type = "-E"
      else
        puts "#{ui.color('Could not get valid type', :magenta)}"
      end
      cmd = Mixlib::ShellOut.new("foodcritic #{type} #{path}")
      cmd.run_command
      puts cmd.stdout
      @error_food = cmd.stderr
      if !@error_food.empty?
        raise FoodCriticError.new("FoodCritic Is not Happy", "ERROR:")
        puts @error_food
        return "notsuccess"
      else
        return "success"
      end
    end

    def upload_roles

      puts "#{ui.color('Creating/Uploading the roles...', :cyan)}"
      files = Dir.glob("/var/lib/jenkins/jobs/validate_iac/workspace/roles/*").select { |f| File.file?(f) }
      files.each do |file|
      fname = Pathname.new(file).basename
        from_role = Chef::Knife::RoleFromFile.new
        from_role.ui = ui
        from_role.name_args = ["/var/lib/jenkins/jobs/validate_iac/workspace/roles/#{fname}"]
        from_role.run
      end
      puts "#{ui.color('.', :cyan)}"
      puts "#{ui.color('Roles were successfully uploaded/created...', :cyan)}"

    end

    def upload_nodes

      puts "#{ui.color('Creating/Uploading the nodes...', :cyan)}"
      files = Dir.glob("/var/lib/jenkins/jobs/validate_iac/workspace/nodes/*").select { |f| File.file?(f) }
      files.each do |file|
      fname = Pathname.new(file).basename
        from_node = Chef::Knife::NodeFromFile.new
        from_node.ui = ui
        from_node.name_args = ["/var/lib/jenkins/jobs/validate_iac/workspace/nodes/#{fname}"]
        from_node.run
      end
      puts "#{ui.color('.', :cyan)}"
      puts "#{ui.color('Nodes were successfully uploaded/created...', :cyan)}"

    end

    def upload_environments

      puts "#{ui.color('Creating/Uploading the environments...', :cyan)}"
      files = Dir.glob("/var/lib/jenkins/jobs/validate_iac/workspace/environments/*").select { |f| File.file?(f) }
      files.each do |file|
      fname = Pathname.new(file).basename
        from_env = Chef::Knife::EnvironmentFromFile.new
        from_env.ui = ui
        from_env.name_args = ["/var/lib/jenkins/jobs/validate_iac/workspace/environments/#{fname}"]
        from_env.run
      end
      puts "#{ui.color('.', :cyan)}"
      puts "#{ui.color('Environments were successfully uploaded/created...', :cyan)}"

    end

    def upload_data_bags

    

    end

    def upload_cookbooks

      puts "#{ui.color('Creating/Uploading the cookbooks...', :cyan)}"
      cookboook = Chef::Knife::CookbookUpload.new
      cookboook.config[:cookbook_path] = '/var/lib/jenkins/jobs/validate_iac/workspace/cookbooks/'
      cookboook.config[:all] = '-a'
      cookboook.run
      puts "#{ui.color('Cookbooks were successfully uploaded/created...', :cyan)}"

    end

    def get_nodes(name,env)
      node_query = Chef::Search::Query.new
      node_found = node_query.search('node', "role:#{name} AND chef_environment:#{env}").first

      return node_found
    end

    def last_chef_run_status(server,env)
      node_name = get_nodes(server,env)
      if node_name.empty?
        puts "#{ui.color('I was unable to find the node with name', :magenta)} :#{server}"
      else
        node_name.each do |node|
        last_run = node['ohai_time']
        last_run_int = time_difference_in_hms(last_run)
        if last_run_int >= 15
          puts "#{ui.color('The last chef-client run in this machine is', :cyan)} :#{last_run_int}"
          puts "#{ui.color('Hence running chef-client before begining the deployment processs', :cyan)}"
          run_chef_here
          return 'ran_chef_here'
        else
          return 'not_necessary_running_chef_here'
        end
        end
      end
    end

    def time_difference_in_hms(raw_time)
      now = Time.now.to_i
      difference = now - raw_time.to_i
      minutes = (difference / 60).to_i
      return minutes
    end

    def run_chef_here
      puts "#{ui.color('******************************', :cyan)}"
      puts "#{ui.color('Running chef-client now', :cyan)}"
      cmd = Mixlib::ShellOut.new("sudo chef-client")
      cmd.run_command
      puts cmd.stdout
      puts "#{ui.color('chef-client ran successfully', :cyan)}"
      puts "#{ui.color('******************************', :cyan)}"
    end

  end

  class FoodCriticError < StandardError
    attr_reader :error

    def initialize(msg="FoodCritic Is not Happy", error="ERROR:")
      @error = error
      super(msg)
    end
  end

  class RubySyntaxError < StandardError
    attr_reader :error

    def initialize(msg="Ruby Syntax Is not Happy", error="ERROR:")
      @error = error
      super(msg)
    end
  end

   class JsonSyntaxError < StandardError
    attr_reader :error

    def initialize(msg="JSON Syntax Is not Happy", error="ERROR:")
      @error = error
      super(msg)
    end
   end

end
