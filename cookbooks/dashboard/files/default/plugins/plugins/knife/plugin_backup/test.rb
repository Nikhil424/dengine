require 'chef/knife'

class Chef
  class Knife
    class Test < Knife

        banner "knife test"

        def run

        test = get_build_verion
        puts test

        end

        def get_build_verion

          data_item_sub = Chef::DataBagItem.new
          data_item_sub.data_bag("job-id")
          data_value_sub = Chef::DataBagItem.load("job-id","job-id")
          data_sub = data_value_sub.raw_data["build-job"]

          return data_sub[-2]

        end

    end
  end
end

