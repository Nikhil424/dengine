require 'chef/knife'

class Chef
  class Knife
    class UpdateJobData < Knife

      banner "knife update job data (options)"

      option :job,
        :short => '-j JOB_NAME',
        :long => '--job JOB_NAME',
        :description => "The name of the jenkins job who's job ID has to be stored"

      option :id,
        :short => '-i JOB_ID',
        :long => '--id JOB_ID',
        :description => "The ID of the jenkins job that hs to be stored"

        def run

          name = config[:job]
          id = config[:id]

          if Chef::DataBag.list.key?("job-id")
            databag = Chef::DataBagItem.load('job-id', 'job-id')
            databag.raw_data["#{name}"] = ["#{id}"]
            databag.save            
          else
            create_data_bag(name,id)
          end

        end

        def create_data_bag(key,value)

          puts ''
          puts "#{ui.color('Was not able to fine databag for this', :cyan)}"
          puts "#{ui.color('Hence creating databag', :cyan)}"
          puts ''
          users = Chef::DataBag.new
          users.name("job-id")
          users.create
          data = {
                 'id' => "job-id",
                 "#{key}" => ["#{value}"]
                 }
          databag_item = Chef::DataBagItem.new
          databag_item.data_bag("job-id")
          databag_item.raw_data = data
          databag_item.save

        end

    end
  end
end
