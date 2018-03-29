require 'chef/knife'

class Chef
  class Knife
    class UpdateDatabag < Knife

        banner "knife check list"

       option :name,
          :short => '-n NETWORK_NAME',
          :long => '--name NETWORK_NAME',
          :description => "The name of the network that has to be created"

        def run

      app = config[:name]

    if Chef::DataBag.list.key?("application")
      puts ''
      puts "#{ui.color('Found databag for this', :cyan)}"
      puts "#{ui.color('Searching data for current application in to the data bag', :cyan)}"
      puts ''
      query = Chef::Search::Query.new
      query_value = query.search(:application, "id:#{app}")
      if query_value == 0

        puts "#{ui.color('Creating application data bag to store application details', :cyan)}"
        users = Chef::DataBag.new
        users.name("application")
        users.create
        data = {
                "id" => "#{app}",
               }
        databag_item = Chef::DataBagItem.new
        databag_item.data_bag("application")
        puts "#{ui.color('Writing data in to the application data bag item', :cyan)}"
        databag_item.raw_data = data
        databag_item.save
        puts "#{ui.color('Data has been written in to application databag successfully', :cyan)}"   

      else

        puts ""
        puts "#{ui.color("The application by name #{app} already exists please check", :cyan)}"
        puts "#{ui.color("Hence we are quiting ", :cyan)}"
        puts ""

      end

    else

      puts "#{ui.color('Creating application data bag to store application details', :cyan)}"
      users = Chef::DataBag.new
      users.name("application")
      users.create
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
