require 'chef/knife'
require "#{File.dirname(__FILE__)}/dengine_autoscaling_client_base"
require "#{File.dirname(__FILE__)}/dengine_autoscaling_base"

module Engine
  class DengineAutoscalingCreate < Chef::Knife

    include DengineAutoscalingBase
    include DengineAutoscalingClientBase

      banner 'knife dengine autoscaling create (options)'

      option :vpc,
        :short => '-v VPC_NAME',
        :long => '--vpc VPC_NAME',
        :description => "The id of the VPC in which auto scaling has to be created"

      option :ami,
        :short => '-a AMI_NAME_NAME',
        :long => '--ami AMI_NAME',
        :description => "The id of the AMI in which auto scaling has to be created"

      option :sg,
        :short => '-g SG_NAME',
        :long => '--sgroup SG_NAME',
        :description => "The id of the SG in which auto scaling has to be created"

      option :elb,
        :short => '-e   ELB_NAME',
        :long => '--elb ELB_NAME',
        :description => "The id of the ELB in which auto scaling has to be created"

    def run
      vpc = config[:vpc]
      ami = config[:ami]
      sg = config[:sg]
      elb = config[:elb]
      puts "#{sg}"
      security = ["#{sg}"]
      subnet_infos = connection_client.describe_subnets({
      :filters => [
        {
          :name =>"vpc-id",
          :values => [vpc]
        },
        ]
      })[:subnets]

      subnet_ids = subnet_infos.map do |subnet|
        subnet[:subnet_id]
      end

      #azs = subnet_infos.map do |subnet|
      #  subnet[:availability_zone]
      #end
      #puts "#{azs}"
      create(ami,security,elb,subnet_ids)
    end

    def create(ami,sg,elb,subnet_ids)
      puts "#{ui.color('creating Launch configuration for the VPC', :cyan)}"
      puts "#{ subnet_ids.shift.strip}"
      #---------------------------Launch configuration---------------------
      #lc = create_launchconfig(ami,sg)
      #---------------------------auto scale group-------------------------
      #asg = create_autoscaling_group(elb,subnet_ids.shift.strip)
      #--------------------------load balancer----------------------------
      llb = attach_elb
    end

end
end 
