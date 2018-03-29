require 'chef/knife'
require 'chef/knife/core/object_loader'
require 'json'

module Eengine
  class DengineEnvPromote < Chef::Knife

    deps do
      require 'chef/search/query'
    end

    banner 'knife dengine env promote SOURCE_ENV DEST_ENV'

    def run
      unless name_args.size == 2
        puts 'Need exactly two arguments.'
        show_usage
        exit 1
      end

      source_env_name = name_args[0]
      dest_env_name   = name_args[1]
      source_env_name = '_default' if source_env_name == 'default'

      puts "Adding cookbook restrictions to the #{dest_env_name} environment based on the #{source_env_name} environment"

      source_cookbooks = cookbooks_in(source_env_name)
      Chef::Log.info "Cookbooks in #{source_env_name}:"
      source_cookbooks.each { |name, version|
        puts "  #{name}: #{version}"
      }

      dest_environment = load_remote_environment(dest_env_name)
      dest_environment.cookbook_versions(source_cookbooks)
      dest_environment.save
    end

    def cookbooks_in source_env_name
      Hash[rest.get_rest("/environments/#{source_env_name}/cookbooks?1").map { |name, info|
        [ name, cookbook_version(info) ]
      }]
    end

    def cookbook_version cookbook
      if cookbook['versions'].empty?
        ''
      else
        cookbook['versions'].first['version']
      end
    end

    def load_remote_environment(environment_name)
      begin
        Chef::Environment.load(environment_name)
      rescue Net::HTTPServerException => e
        ui.error "Could not load #{environment_name} from Chef Server. You must upload the environment manually the first time."
        exit(1)
      end
    end

  end
end
