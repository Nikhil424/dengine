require 'chef/knife'

class Chef
  class Knife
    class Data < Knife

     banner "knife data (options)"

        def run

          value = fetch_data
          puts value.first
          puts value.last

        end

        def fetch_data

        data_item_sub = Chef::DataBagItem.new
        data_item_sub.data_bag('job-id')
        data_value_sub = Chef::DataBagItem.load('job-id','job-id')
        data_sub = data_value_sub.raw_data['build-job']

        return data_sub

        end

    end
  end
end
