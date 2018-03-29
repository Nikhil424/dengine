require 'chef/knife'

class Chef
  class Knife
    class CheckList < Knife

        banner "knife check list"

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
         name = 'game-tomcat-development-1'
         role = 'tomcat'
         chek_node_existence_and_set(name)
#         puts "the value of test is #{test}"
#         create_application_data_bag("game")

      end

#---------------------------------------------------------------------------------
      def get_nodes(name)

        node_query = Chef::Search::Query.new
#        node_found = node_query.search('node', "name:#{name}").first
        node_found = node_query.search('node', "name:#{name}").first
        return node_found
      end

      def search_databag_item
        data_item = Chef::DataBagItem.new
        data_item.data_bag("job_id")
        query_value = data_item.validate_id!("job-id")
        puts "#{query_value}"
        if query_value == 0
          return 0
        else
          return 1
        end
      end

      def search_databag
        databag_item = Chef::DataBagItem.new
        if Chef::DataBag.list.key?("job_id")
          return 0
        else
          return 1
        end
      end

      def chek_node_existence_and_set(name)

        data = search_databag
        if data == 0

          item = search_databag_item
          if item == 0

            puts "from if condition"
            #set_node_to_old_value(name)

          else
            puts "calling from first else"
            #set_node_for_first(name)

          end

        else
          puts "calling from outside else"
          #set_node_for_first(name)

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
        puts "#{ui.color('I am from outside else', :cyan)}"
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
#--------------------------------------------------------------------------------
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

    end
  end
end
