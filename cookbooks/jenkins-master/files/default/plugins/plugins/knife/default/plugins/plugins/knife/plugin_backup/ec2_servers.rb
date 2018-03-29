require 'fog/aws'
require 'fog/aws/parsers/compute/create_image'
require 'fog/aws/requests/compute/create_image'
require 'chef/knife/ec2_base'
require 'chef/knife'
include Fog::Compute
include Fog::Parsers::Compute::AWS
class Chef
  class Knife
    class Ec2ServerAction < Knife;AWS

      include Fog::Parsers::Compute::AWS
      include Fog::Compute
      include Knife::Ec2Base
      banner 'knife ec2 server action OPTION(start,stop) INSTANCE-ID'
	  
      def run
        unless name_args.size == 2
          show_usage
          Chef::Application.fatal! 'Wrong number of arguments'
        end

        instance_id = name_args[1]
        option = name_args[0]

        puts "Instance Id you entered is #{instance_id}"
        puts "The option you selected is to #{option} the server"
        puts '.'
        
        aws_credentials = {
           :aws_access_key_id => 'AKIAJWKPC5BBR6DZHLNQ',
           :aws_secret_access_key => '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'
        }
        fog = Fog::Compute.new(aws_credentials.merge(:provider => 'AWS',:region => 'us-west-2'))

        Chef::Log.debug "Found server with the instance_id you given, we are performing the action specified by you"
        #test = AWS.servers.get(instance_id)
        #print ui.color("the details of server are#{test}", :bold)

        if option == 'start'
          print ui.color("We are starting server with ID #{instance_id}", :bold)
          fog.start_instances(instance_id)
          puts '.'
          puts '.'
          puts 'Server has been started'
          puts '.'
          puts 'The operation is complete'
        elsif option == 'stop'
          print ui.color("We are stoping server with ID #{instance_id}", :bold)
          fog.stop_instances(instance_id)
          puts '.'
          puts '.'
          puts 'Server has been stoped'
          puts '.'
          puts 'The operation is complete'
        else
          puts 'The operation is incomplete'
          puts 'You did not select the appropriate option...!! try again'
          puts '.'
        end
      end
    end
  end
end
