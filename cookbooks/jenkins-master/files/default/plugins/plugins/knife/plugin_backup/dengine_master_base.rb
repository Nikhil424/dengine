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
        if query_value == 0

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
      ip = node["cloud_v2"]["public_ipv4"]
      end
      return ip

    end

    def save_server_details(app,env,servers)
      $no_server = servers.size
      value = Array.new
      n1 = servers.size-1
      servers.each {|i|
                    ip = fetch_ipaddress(i);
                    value[n1] = set_env_for(env,i,ip);
                    n1 -=1
      }
      n = value.size
      until n == 0 do
      if n == 2
        url  = "http://#{value[1]}:8080"
        type = "tomcat"
        name = servers[0]
      elsif n == 1
        url  = "#{value[0]}"
        type = "mysql"
        name = servers[1]
      end
        puts "The url is #{url}"
        puts "The type is #{type}"
        store_item(app,"#{name}","#{url}","#{env}_servers","#{type}")
        sleep(10)
        n -=1
      end
    end

    def store_uat_prod_server_details(app,uat_servers,prod_servers)

      store_item(app,"#{uat_servers.value[1]}","#{fetch_ipaddress("#{uat_servers.value[1]}")}","acceptance_servers","mysql")
      sleep(10)
      uat_ip = {}
      n = uat_servers.value[0].size-1
      uat_servers.value[0].each {|i|
                                  puts "from uat_servers.each function and I got #{i}";
                                  ip = fetch_ipaddress(i);
                                  store_item(app,"#{i}","http://#{ip}:8080","acceptance_servers","tomcat#{n}");
                                  n -=1;
                                  sleep(10)
      }
    #-----------Saving Prod server details--------
      store_item(app,"#{prod_servers.value[1]}","#{fetch_ipaddress("#{prod_servers.value[1]}")}","production_servers","mysql")
      sleep(10)
      uat_ip = {}
      m = prod_servers.value[0].size-1
      prod_servers.value[0].each {|i|
                                  puts "from prod_servers.each function and I got #{i}";
                                  ip = fetch_ipaddress(i);
                                  store_item(app,"#{i}","http://#{ip}:8080","production_servers","tomcat#{m}");
                                  m -=1;
                                  sleep(10)
      }

    end

    def set_env_for(env,i,ip)

      if env == "development"
        dev_ip = {}
        dev_ip.store(i,ip)
        return dev_ip.values.to_s.tr("[]", '').tr('"', '')
      elsif env == "testing"
        test_ip = {}
        test_ip.store(i,ip)
        return test_ip.values.to_s.tr("[]", '').tr('"', '')
      elsif env == "acceptance"
        uat_ip = {}
        uat_ip.store(i,ip)
        return uat_ip.values.to_s.tr("[]", '').tr('"', '')
      elsif env == "production"
        prod_ip = {}
        prod_ip.store(i,ip)
        return prod_ip.values.to_s.tr("[]", '').tr('"', '')
      end

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

  end
end
