require 'chef/knife'

module Engine
    module DengineAwsServerBase

      def get_env(env)

        data_item_env = Chef::DataBagItem.new
        data_item_env.data_bag("network")
        data_value_env = Chef::DataBagItem.load("network",env)
        data_env = data_value_env.raw_data['SUBNET-ID']

      end

      def get_security_group(env)

        data_item_sg = Chef::DataBagItem.new
        data_item_sg.data_bag("network")
        data_value_sg = Chef::DataBagItem.load("network",env)
        data_sg = data_value_sg.raw_data['SECURITY-ID']

      end

      def get_vpc_id(env)

        data_item_sg = Chef::DataBagItem.new
        data_item_sg.data_bag("network")
        data_value_sg = Chef::DataBagItem.load("network",env)
        data_sg = data_value_sg.raw_data['VPC-ID']

      end

      def get_subnet_id(env)

        data_item_sub = Chef::DataBagItem.new
        data_item_sub.data_bag("network")
        data_value_sub = Chef::DataBagItem.load("network",env)
        data_sub = data_value_sub.raw_data['SUBNET-ID']

        return data_sub
      end

      def get_nodes(name)

        node_query = Chef::Search::Query.new
        node_found = node_query.search('node', "name:#{name}").first

        return node_found
      end

      def search_databag_item
        query = Chef::Search::Query.new
        query_value = query.search(:job_id, "id:job-id")
        if query_value == 0
          return true
        else
          return false
        end
      end

      def chek_node_existence_and_set(node_name)

        if Chef::DataBag.list.key?("job_id")

          if search_databag_item == false

            set_node_to_old_value(node_name)

          else

            puts "calling from first else"
            set_node_for_first(node_name)

          end

        else

          puts "calling from outside else"
          set_node_for_first(node_name)

        end

      end

      def get_build_verion

        data_item_sub = Chef::DataBagItem.new
        data_item_sub.data_bag("job_id")
        data_value_sub = Chef::DataBagItem.load("job_id","job-id")
        data_sub = data_value_sub.raw_data["build-job"]

        return data_sub.last,data_sub[-2]

      end

      def set_node_to_old_value(node_name)
        puts "#{ui.color('====================================', :cyan)}"
        puts "#{ui.color('Found databag for this', :cyan)}"
        puts "#{ui.color('Which means I can sense my existence before', :cyan)}"
        puts "#{ui.color('Setting values with my old existence', :cyan)}"
        puts "#{ui.color('', :cyan)}"
        versions = get_build_verion
        node_found = get_nodes(node_name)
        puts node_found
        node_found.each do |node|
          puts "#{ui.color('Seting attributes for node started', :cyan)}"
          node.set['dengine']['artifact']['name']          = 'gameoflife-web'
          node.set['dengine']['artifact']['version']       = "#{versions.first}"
          node.set['dengine']['artifact']['rollversion']   = "#{versions.last}"
          node.set['dengine']['artifact']['deployment']    = "false"
          node.save
          puts "#{ui.color('setting attributes for the node is complete', :cyan)}"
        end
        puts "#{ui.color('', :cyan)}"
        puts "#{ui.color('The node is set to the previous state', :cyan)}"
        puts "#{ui.color('====================================', :cyan)}"
      end

      def set_node_for_first(node_name)
        puts "#{ui.color('====================================', :cyan)}"
        puts "#{ui.color('I am getting created for the first time, hence I am assigned with default values', :cyan)}"
        node_found = get_nodes(node_name)
        node_found.each do |node|
          puts "#{ui.color('Seting attributes for node started', :cyan)}"
          node.set['dengine']['artifact']['name']          = 'gameoflife-web'
          node.set['dengine']['artifact']['version']       = '0.0'
          node.set['dengine']['artifact']['rollversion']   = '0.0'
          node.set['dengine']['artifact']['deployment']    = "false"
          node.save
          puts "#{ui.color('setting attributes for the node is complete', :cyan)}"
        end
        puts "#{ui.color('====================================', :cyan)}"
      end

  end
end
