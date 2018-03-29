require 'chef/knife'
require "#{File.dirname(__FILE__)}/dengine_elb_base"

module Engine
  class DengineElbAddInstance < Chef::Knife

      include DengineElbBase

      banner 'knife dengine elb add instance (options)'

      option :elb_name,
        :short => '-n ELB-NAME',
        :long => '--name_elb ELB-NAME',
        :description => "The name of load balancer in which the server has to be added"

       option :instance_id,
        :short => '-i INSTANCE-ID',
        :long => '--instance_id INSTANCE-ID',
        :description => 'The ID of instance which has to be added to the LB-pool'

      def run

       elb_name = config[:elb_name]
       instance_id = config[:instance_id]
       target_arn = get_target_arn(elb_name)
       arn = target_arn[0].to_s
       puts "The elb name #{elb_name}"
       puts "The target arn #{arn}"
       puts "#{ui.color('Adding server to load balancer', :cyan)}"
       connection_elb.register_targets({
         target_group_arn: arn, 
         targets: [
         {
           id: instance_id,
         },
         ],
       })

      end

      def get_target_arn(name)
        puts "#{ui.color('fetching target ARN from databag', :cyan)}"
        data_item_env = Chef::DataBagItem.new
        data_item_env.data_bag("loadbalancers")
        data_value_env = Chef::DataBagItem.load("loadbalancers",name)
        data_env = data_value_env.raw_data['TARGET-GROUP-ARN']

      end

  end
end
