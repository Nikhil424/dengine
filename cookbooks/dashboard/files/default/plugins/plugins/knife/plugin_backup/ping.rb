require 'chef/knife'
require 'net/ping'

class Chef
  class Knife
    class Ping < Knife

      banner "knife ping"

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
        
        node_name = get_nodes(name,env)
	    node_ip = fetch_ipaddress(name)
        ping_path = "http://#{node_ip}/"

        pingfails = 0
        repeat = 5
        (1..repeat).each do
          pinging = Net::Ping::HTTP.new(ping_path)
          if pinging.ping
            puts "#{ui.color('The duration with in which I got reply is', :cyan)} :#{pinging.duration}"
          else 
            pingfails += 1
            puts "#{ui.color('The ping is failing, the number of packets dropped were', :cyan)} :#{pingfails}"
          end
        end
      end

      def get_nodes(name,env)

        node_query = Chef::Search::Query.new
        node_found = node_query.search('node', "name:#{name} AND chef_environment:#{env}").first

      return node_found
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
end
