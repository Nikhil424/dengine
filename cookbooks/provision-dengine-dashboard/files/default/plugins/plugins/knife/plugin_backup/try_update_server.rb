require 'chef/knife'
require "#{File.dirname(__FILE__)}/dengine_update_databag"

module Engine
  class TryUpdateServer < Chef::Knife

    def self.included(includer)
      includer.class_eval do
        deps do
          require 'chef/search/query'
        end
      end
    end

    deps do
      DengineApp::DengineUpdateDatabag.load_deps
    end

    banner 'knife try update server (options)'

    def run
      servers = ["jenkins-demo","dashboard-machine"] 
      env = "testing"
      app = "java"
      save_server_details(app,env,servers)
    end

    def save_server_details(app,env,servers)
      $no_server = servers.size
      value = Array.new
      n1 = servers.size-1
      servers.each {|i|
                                ip = fetch_ipaddress(i);
                                value[n1] = set_env_for(env,i,ip);
                                puts "#{value[n1]}"
                                n1 -=1
      }
      puts value.size
      puts value[0]
      puts value[1]
      puts value.size
      puts servers.size
      puts servers[1]
      n = value.size
      puts n
      until n == 0 do
      if n == 2 
        url  = "http://#{value[1]}:3000"
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
    def store_item(app,name,url,servers_category,servers_type)

      puts "+++++++++++++++++++++++++++++++++++++++"
      puts "#{name}"
      puts "#{url}"
      puts "#{servers_category}"
      puts "#{servers_type}"
      puts "+++++++++++++++++++++++++++++++++++++++"
      data = DengineApp::DengineUpdateDatabag.new
      data.config[:app_name]         = app
      data.config[:name]             = name
      data.config[:url]              = url
      data.config[:servers_category] = servers_category
      data.config[:servers_type]     = servers_type

      data.run

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

  end
end
