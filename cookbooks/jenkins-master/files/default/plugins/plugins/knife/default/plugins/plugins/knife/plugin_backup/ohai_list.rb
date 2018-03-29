require 'chef/knife'

class Chef
  class Knife
    class OhaiList < Knife

        banner "knife ohai list"

        def run
        new_version = '2.0'
        #exec = Chef::Knife::Exec.new
        #exec.config[:exec] = "nodes.find(:name => 'dengine-test-machine') { |node|  node.set['dengine']['app']['version'] = #{new_version} ; node.save; }"
        #exec.run
          
          #node_name = node[dengine-test-machine]
          #node_name = Array.new
          #Chef::Log.info "Preparing node #{node_name.name} for deployment"
          #  value.override['dengine']['app']['version'] = new_version
          #  value.save
          #puts "#{value}"
          



#---------------------------------------------------------------------------------
        search = Chef::Knife::Search.new
        search.name_args = ['node', "name:maven-machine"]
        out = search.run
        puts out
        value = Array.new
        out.each do |node|
        value = node['platform']
        puts value
        end
        puts "Node name is set"
#----------------------------------------------------------------------------------
opts = { filter_result:
                 { name: ["name"], ipaddress: ["ipaddress"], ohai_time: ["ohai_time"],
                   ec2: ["ec2"], run_list: ["run_list"], platform: ["platform"],
                   platform_version: ["platform_version"], chef_environment: ["chef_environment"] } }
        @query = "*:*"
        all_nodes = []
        q = Chef::Search::Query.new
        Chef::Log.info("Sending query: #{@query}")
        q.search(:node, @query, opts) do |node|
          all_nodes << node
        end

output(all_nodes.sort do |n1, n2|
          if config[:sort_reverse] || Chef::Config[:knife][:sort_status_reverse]
            (n2["ohai_time"] || 0) <=> (n1["ohai_time"] || 0)
          else
            (n1["ohai_time"] || 0) <=> (n2["ohai_time"] || 0)
          end
        end)

#--------------------------------------------------------------------------------
        end
    end
  end
end

