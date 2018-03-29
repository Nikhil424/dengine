require 'chef/knife'
require 'json'

class Chef
  class Knife
    class JobData < Knife

      banner "knife job data (options)"

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

          data_bag_dir = "/root/chef-repo/data_bags/#{name}"
          if ensure_dir(data_bag_dir) == true

            file_location = "#{data_bag_dir}/#{name}.json"
            update_data_bag_item(file_location,id,name)

          else 

            puts "#{ui.color('Was not able to find data_bag for this', :cyan)}"
            puts "#{ui.color('Creating a new data_bag with the name: job-id', :cyan)}"
            system("knife data bag create #{name}")
            system("mkdir /root/chef-repo/data_bags/#{name}")
            puts "#{ui.color('The data_bag is created', :cyan)}"
            update_data_bag_item(file_location,id,name)

          end

        end

        def ensure_dir(location)

          if Dir.exists? "#{location}"
            return true
          else
            return false
          end

        end

        def ensure_file(location)

          if File.exists? "#{location}"
            return true
          else
            return false
          end

        end

        def update_data_bag(file_location,id,name)

          file = File.read "#{file_location}"
          data = JSON.parse("#{file}")
          value = data["build-job"]
          update_value = value.push("#{id}")
          data["build-job"] = update_value
          File.open(file_location, 'w') { |file| file.write(data.to_json) }
          system("knife data bag from file #{name} #{file_location}")

        end

        def update_data_bag_item(file_location,id,name)

          if ensure_file(file_location) == true

            update_data_bag(file_location,id,name)

          else

            puts "#{ui.color('Was not able to find data_bag_item for this', :cyan)}"
            puts "#{ui.color('Creating a new data_bag_item with the name: job-id', :cyan)}"
            system("cp /root/chef-repo/templates/#{name}.json /root/chef-repo/data_bags/#{name}/#{name}.json")
            system("knife data bag from file #{name} #{file_location}")
            update_data_bag(file_location,id,name)

          end

        end

    end
  end
end
