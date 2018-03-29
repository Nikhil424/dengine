require 'chef/knife'

module Engine
  module DengineMasterBase

    def self.included(includer)
      includer.class_eval do
        deps do
          require 'chef/search/query'
        end
      end
    end

    def create_application_data_bag(app)

      if Chef::DataBag.list.key?("application")
        puts ''
        puts "#{ui.color('Found databag for this', :cyan)}"
        puts "#{ui.color('Searching data for current application in to the data bag', :cyan)}"
        puts ''
        query = Chef::Search::Query.new
        query_value = query.search(:application, "id:#{app}")
        if query_value[2] == 1

          puts ""
          puts "#{ui.color("The application by name #{app} already exists please check", :cyan)}"
          puts "#{ui.color("Hence we are quiting ", :cyan)}"
          puts ""
          exit

        else

          puts "#{ui.color('Creating application data bag item to store application details', :cyan)}"
          data = {
                  "id" => "#{app}",
                 }
          databag_item = Chef::DataBagItem.new
          databag_item.data_bag("application")
          puts "#{ui.color('Writing data in to the application data bag item', :cyan)}"
          databag_item.raw_data = data
          databag_item.save
          puts "#{ui.color('Data has been written in to application databag successfully', :cyan)}"

        end

      else

        puts ''
        puts "#{ui.color('Was not able to find databag for this', :cyan)}"
        puts "#{ui.color('Hence creating databag', :cyan)}"
        puts ''
        users = Chef::DataBag.new
        users.name("application")
        users.create
        puts "#{ui.color('Creating application data bag item to store application details', :cyan)}"
        data = {
                 "id" => "#{app}",
               }
        databag_item = Chef::DataBagItem.new
        databag_item.data_bag("application")
        puts "#{ui.color('Writing data in to the application data bag item', :cyan)}"
        databag_item.raw_data = data
        databag_item.save
        puts "#{ui.color('Data has been written in to application databag successfully', :cyan)}"

      end
    end

    def create_application_data_bag_for_environment(app)

      if Chef::DataBag.list.key?("application")
        puts ''
        puts "#{ui.color('Found databag for this', :cyan)}"
        puts "#{ui.color('Searching data for current application in to the data bag', :cyan)}"
        puts ''
        query = Chef::Search::Query.new
        query_value = query.search(:application, "id:#{app}")
        if query_value[2] == 1

          puts ""
          puts "#{ui.color("The application by name #{app} already exists ", :cyan)}"
          puts "#{ui.color("Hence we are proceeding ", :cyan)}"
          puts ""

        else

          puts "#{ui.color('Creating application data bag item to store application details', :cyan)}"
          data = {
                  "id" => "#{app}",
                 }
          databag_item = Chef::DataBagItem.new
          databag_item.data_bag("application")
          puts "#{ui.color('Writing data in to the application data bag item', :cyan)}"
          databag_item.raw_data = data
          databag_item.save
          puts "#{ui.color('Data has been written in to application databag successfully', :cyan)}"

        end

      else

        puts ''
        puts "#{ui.color('Was not able to find databag for this', :cyan)}"
        puts "#{ui.color('Hence creating databag', :cyan)}"
        puts ''
        users = Chef::DataBag.new
        users.name("application")
        users.create
        puts "#{ui.color('Creating application data bag item to store application details', :cyan)}"
        data = {
                 "id" => "#{app}",
               }
        databag_item = Chef::DataBagItem.new
        databag_item.data_bag("application")
        puts "#{ui.color('Writing data in to the application data bag item', :cyan)}"
        databag_item.raw_data = data
        databag_item.save
        puts "#{ui.color('Data has been written in to application databag successfully', :cyan)}"

      end
    end

    def fetch_instance_id(node)

      search = Chef::Knife::Search.new
      search.name_args = ['node', "name:#{node}"]
      out = search.run
      value = Array.new
      out.each do |node|
      value = node["ec2"]["instance_id"]
      end
      return value

    end

    def fetch_ipaddress(node)

      search = Chef::Knife::Search.new
      search.name_args = ['node', "name:#{node}"]
      out = search.run
      ip = Array.new
      out.each do |node|
      ip = node["cloud"]["public_ipv4"]
      end
      return ip

    end

    def store_elb_details_in_serverdetails(elb,env)
      if Chef::DataBag.list.key?("serverdetails")
        puts ''
        puts "#{ui.color('Found databag for this', :cyan)}"
        puts "#{ui.color('Searching data for current application in to the data bag', :cyan)}"
        puts ''
        query = Chef::Search::Query.new
        query_value = query.search(:serverdetails, "id:#{env}")
        if query_value == 0

          puts ""
          puts "#{ui.color('The serverdetails for this application does not exists, hence I cannot store value here', :cyan)}"
          puts ""

        else

          puts ""
          puts "#{ui.color("Serverdetails for #{env} exists", :cyan)}"
          puts "#{ui.color('Writing data bag item to store ELB in serverdetails details', :cyan)}"
          data = {
                  "elb": "#{elb}",
                 }
          serverdatabag = Chef::DataBagItem.load('serverdetails', env)
          puts "#{ui.color('Writing data in to the data bag item', :cyan)}"
          serverdatabag.raw_data["#{env}"] = data
          serverdatabag.save
          puts "#{ui.color('Data has been written in to databag successfully', :cyan)}"
          puts ""

        end

      else

        puts ""
        puts "#{ui.color('serverdetails data bag is not created and I am not authorized to create it', :cyan)}"
        puts "#{ui.color('Hence I am not storing value', :cyan)}"
        puts ""

      end
    end

    def store_item(name,url,servers_category,servers_type)

      puts puts "#{ui.color('+++++++++++++++++++++++++++++++++++++++', :magenta)}"
      puts "#{name}"
      puts "#{url}"
      puts "#{servers_category}"
      puts "#{servers_type}"
      puts puts "#{ui.color('+++++++++++++++++++++++++++++++++++++++', :magenta)}"

      if Chef::DataBag.list.key?("serverdetails")

        puts ''
        puts "#{ui.color('Found databag for this', :cyan)}"
        puts "#{ui.color('Writing data in to the data bag item', :cyan)}"
        puts ''
        query = Chef::Search::Query.new
        query_value = query.search(:serverdetails, "id:#{servers_category}")
        if query_value.last == 0
          create_data_bag_item(name,url,servers_category,servers_type)
        else
          update_data_bag_item(name,url,servers_category,servers_type)
        end

      else
        puts ''
        puts "#{ui.color('Was not able to find databag for this', :cyan)}"
        puts "#{ui.color('Hence creating databag', :cyan)}"
        puts ''
        create_data_bag(name,url,servers_category,servers_type)
      end

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

    def update_data_bag_item(name,url,servers_cat,servers_type)

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

    def get_url(role,node_ip)

      case role
      when "sensu"
        url = "http://#{node_ip}:3000"
      when "jfrog"
        url = "http://#{node_ip}:8081/artifactory"
      when "jenkins"
        url = "http://#{node_ip}:8080"
      when "tomcat"
        url = "http://#{node_ip}:8080"
      when "splunk"
        url = "http://#{node_ip}"
      when "maven"
        url = "#{node_ip}"
      when "mysql"
        url = "#{node_ip}"
      when "redis"
        url = "#{node_ip}"
      when "elasticsearch"
        url = "#{node_ip}"
      when "web"
        url = "http://#{node_ip}:80"
      else
        puts "#{ui.color('I have got nothing to send as a URL, please check this', :magenta)}"
      end

      return url
    end

    def get_server_type(role,id)

      case role
      when ("sensu" || "datadog" || "nagios")
        type = "monitoring"
      when ("jfrog" || "nexus")
        type = "artifactory"
      when ("jenkins" || "teamcity" || "bamboo")
        type = "integration"
      when "splunk"
        type = "log-management"
      when ("maven" || "gradle" || "phing" || "ant")
        type = "build"
      when "web"
        type = "webserver-#{id}"
      when "tomcat"
        type = "webserver-#{id}"
      when ("mysql" || "oracle" || "mongodb")
        type = "database"
      when ("redis")
        type = "in-memory-database"
      when ("elasticsearch" || "solar")
        type = "search-engine"
      else
        puts "#{ui.color('I have got nothing to send as a URL, please check this', :magenta)}"
      end

      return type
    end

  end
end
