require 'chef/knife'
require 'json'

module DengineApp
    class DengineUpdateDatabag < Chef::Knife

      banner "knife update databag (options)"

      option :app_name,
        :short => '-a APP_NAME',
        :long => '--app_name APP_NAME',
        :description => "The name of the application that has to be deployed"

      option :name,
        :short => '-n APP_NAME',
        :long => '--name APP_NAME',
        :description => "The name of the node that has to be updated in the data bag"

      option :url,
        :short => '-u ENV_NAME',
        :long => '--url ENV_NAME',
        :description => "The name of the environment where the app has to be deployed"

      option :servers_category,
        :short => '-s ENV_NAME',
        :long => '--servers_category ENV_NAME',
        :description => "The name of the environment where the app has to be deployed"

      option :servers_type,
        :short => '-t ENV_NAME',
        :long => '--servers_type ENV_NAME',
        :description => "The name of the environment where the app has to be deployed"

        def run

          app = config[:app_name]
          name = config[:name]
          url = config[:url]
          servers_category = config[:servers_category]
          servers_type = config[:servers_type]
          store_item(app,name,url,servers_category,servers_type)

        end

        def store_item(app,name,url,servers_category,servers_type)
          servers_cat = fetch_category(servers_category,app)
          if Chef::DataBag.list.key?("serverdetails")

            puts ''
            puts "#{ui.color('Found databag for this', :cyan)}"
            puts "#{ui.color('Writing data in to the data bag item', :cyan)}"
            puts ''
            query = Chef::Search::Query.new
            query_value = query.search(:serverdetails, "id:#{servers_cat}")
            if query_value.last == 0
              create_data_bag_item(name,url,servers_cat,servers_type)
            else
              update_data_bag(name,url,servers_cat,servers_type)
            end

          else
            puts ''
            puts "#{ui.color('Was not able to find databag for this', :cyan)}"
            puts "#{ui.color('Hence creating databag', :cyan)}"
            puts ''
            create_data_bag(name,url,servers_cat,servers_type)
          end

        end

        def update_data_bag(name,url,servers_cat,servers_type)

          data = {
                 "node_name": "#{name}",
                 "url": "#{url}"
                 }
          serverdatabag = Chef::DataBagItem.load('serverdetails', servers_cat)
          puts "#{ui.color('Writing data in to the data bag item', :cyan)}"
          serverdatabag.raw_data["#{servers_type}"] = data
          serverdatabag.save
          puts "#{ui.color('Data has been written in to databag successfully', :cyan)}"

        end

        def create_data_bag(name,url,servers_cat,servers_type)

          users = Chef::DataBag.new
          users.name("serverdetails")
          users.create
          data = {
                  "id" => "#{servers_cat}",
                  "#{servers_type}" => {
                    "node_name"=> "#{name}",
                    "url" => "#{url}"
                  }
                 }
          databag_item = Chef::DataBagItem.new
          databag_item.data_bag("serverdetails")
          puts "#{ui.color('Writing data in to the data bag item', :cyan)}"
          databag_item.raw_data = data
          databag_item.save
          puts "#{ui.color('Data has been written in to databag successfully', :cyan)}"

        end

        def create_data_bag_item(name,url,servers_cat,servers_type)

          data = {
                  "id" => "#{servers_cat}",
                  "#{servers_type}" => {
                    "node_name"=> "#{name}",
                    "url" => "#{url}"
                  }
                 }
          databag_item = Chef::DataBagItem.new
          databag_item.data_bag("serverdetails")
          puts "#{ui.color('Writing data in to the data bag item', :cyan)}"
          databag_item.raw_data = data
          databag_item.save
          puts "#{ui.color('Data has been written in to databag successfully', :cyan)}"

        end

        def fetch_category(servers_category,app)

          if servers_category == 'management_servers'
            return "#{app}_management_servers"
          elsif servers_category == 'acceptance_servers'
            return "#{app}_acceptance_servers"
          elsif servers_category == 'development_servers'
            return "#{app}_development_servers"
          elsif servers_category == 'testing_servers'
            return "#{app}_testing_servers"
          elsif servers_category == 'production_servers'
            return "#{app}_production_servers"
          else
            return "#{app}_demo_servers"
          end

        end

  end
end
