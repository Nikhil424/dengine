require 'chef/dsl'
require 'fileutils'
require 'chef/knife'

  include Chef::DSL::IncludeAttribute
  include Chef::DSL::IncludeRecipe

module AttributeNode

  def chek_node_existence

    if Chef::DataBag.list.key?("job-id")

#      query = Chef::Search::Query.new
      query_value = search("job-id", "id:job-id")
      if query_value == 0

        Chef::Log.info("====================================")
        Chef::Log.info("Found databag for this")
        Chef::Log.info("Which means I can sense my existence before")
        Chef::Log.info("Setting values to old node's")
        Chef::Log.info("")
        include_recipe 'dengine::set_node_attribute'
        Chef::Log.info("")
        Chef::Log.info("====================================")

      else

          Chef::Log.info("====================================")
          Chef::Log.info("I am getting created for the first time, hence I am assigned with default values")
          include_attribute "dengine::dengine"
          Chef::Log.info("====================================")

      end

    else

      Chef::Log.info("====================================")
	  Chef::Log.info("I am getting created for the first time, hence I am assigned with default values")
      include_attribute "dengine::dengine"
      Chef::Log.info("====================================")

    end

  end

  def get_build_verion

    data_item_sub = Chef::DataBagItem.new
    data_item_sub.data_bag("job-id")
    data_value_sub = Chef::DataBagItem.load("job-id","job-id")
    data_sub = data_value_sub.raw_data["build-job"]

    return data_sub.last,data_sub[-2]

  end

end
