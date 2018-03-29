require 'chef/knife'

module Engine
  module DengineDataTresure

    def check_role(role)
      query = Chef::Search::Query.new
      chef_role = query.search('role', "name:#{role}").first
#      crap_out "No role '#{role}' found on the server" if chef_role.empty?
      chef_role.first
    end

    def set_node_name(app_name,role,chef_env,id)
      "#{app_name}-#{role}-#{chef_env}-#{id}"
    end

    def set_runlist(role)
        ["role[#{role}]"]
    end

    def fetch_data(data_bag,databag_item,resource)

      data_item_sg = Chef::DataBagItem.new
      data_item_sg.data_bag(data_bag)
      data_value_sg = Chef::DataBagItem.load(data_bag,databag_item)
      data_sg = data_value_sg.raw_data["#{resource}"]

    end

    def get_nodes(name)

      node_query = Chef::Search::Query.new
      node_found = node_query.search('node', "name:#{name}").first

      return node_found
    end

#---The following functions will help in setting node attribute for deployment---------------

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
      puts "the node name: #{node_name}"
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

    def get_target_arn(name)

      puts "#{ui.color('fetching target ARN from databag', :cyan)}"
      data_item_env = Chef::DataBagItem.new
      data_item_env.data_bag("loadbalancers")
      data_value_env = Chef::DataBagItem.load("loadbalancers",name)
      data_env = data_value_env.raw_data['TARGET-GROUP-ARN']
    end

#-------------This function is being called by both network and loadbalancers create-------
#----------used to check the existence of resources present is appopriate cloud------------

    def check_resource_existence(resource,resource_item)
      if Chef::DataBag.list.key?(resource)
        puts ''
        puts "#{ui.color('Found databag for this', :cyan)}"
        puts "#{ui.color('Searching data for current application in to the data bag', :cyan)}"
        puts ''
        query = Chef::Search::Query.new
        query_value = query.search(:"#{resource}", "id:#{resource_item}")
        if query_value[2] == 1
          puts ""
          puts "#{ui.color("The loadbalancer by name #{resource_item} already exists please check", :cyan)}"
          puts "#{ui.color("Hence we are quiting ", :cyan)}"
          puts ""
          exit
        else
          puts "#{ui.color("The data bag item #{resource_item} is not present")}"
          puts "#{ui.color("Hence we are Creating #{resource_item} ", :cyan)}"
          return 0
        end
      else
        puts ''
        puts "#{ui.color("Didn't found databag for this", :cyan)}"
        puts "#{ui.color("Hence we are Creating #{resource_item}_network ", :cyan)}"
        return 0
      end
    end

  end
end
