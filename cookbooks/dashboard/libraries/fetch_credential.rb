require 'chef/dsl'
require 'fileutils'
require 'chef/knife'

  include Chef::DSL::IncludeRecipe

module FetchCredential

  def fetch_cred

    data_item = Chef::DataBagItem.new
    data_item.data_bag("dengine")
    data_value = Chef::DataBagItem.load("dengine","bitbucket")

    return data_value.raw_data['username'].to_s,data_value.raw_data['pasword'].to_s

  end

end

