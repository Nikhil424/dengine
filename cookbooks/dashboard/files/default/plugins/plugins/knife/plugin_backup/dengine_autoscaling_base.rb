require 'chef/knife'
require "#{File.dirname(__FILE__)}/dengine_autoscaling_client_base"

module Engine
  module DengineAutoscalingBase

    include DengineAutoscalingClientBase

    def create_launchconfig(ami,sg)
      puts "#{ui.color('launch configuration creation has been started', :cyan)}"
      vpc_create  = autoscaling_client.create_launch_configuration({
      image_id: ami,
      key_name: "new-iac-coe",
      instance_type: "t2.micro",
      launch_configuration_name: "basnik",
      security_groups: sg,
      })
    end

    def create_autoscaling_group(elb,subnet_ids_str)
      puts "#{ui.color('auto scaling group creation has been started', :cyan)}"
      esp = autoscaling_client.create_auto_scaling_group({
        auto_scaling_group_name: "basnik",
        health_check_grace_period: 120,
        # availability_zones: azs,
        #load_balancer_names: ["AutoScalingdemo"],
        #target_group_arns: ["arn:aws:elasticloadbalancing:us-west-2:074567822052:loadbalancer/app/AutoScalingdemo/cb8825c073832300"],
        health_check_type: "EC2",
        launch_configuration_name: "basnik",
        max_size: 3,
        min_size: 1,
        vpc_zone_identifier: subnet_ids_str,
      })
      scale_up_policy_arn = autoscaling_client.put_scaling_policy({
       auto_scaling_group_name: "basnik",
       policy_name: "scale up policy",
       scaling_adjustment: 1,
       adjustment_type: "ChangeInCapacity",
       cooldown: 200
      })[:policy_arn]
      scale_down_policy_arn = autoscaling_client.put_scaling_policy({
        auto_scaling_group_name: "basnik",
        policy_name: "scale down policy",
        scaling_adjustment: -1,
        adjustment_type: "ChangeInCapacity",
        cooldown: 200
      })[:policy_arn]
    end

    def attach_elb
      puts "#{ui.color('attaching load balancer to auto scaling group', :cyan)}"
      autoscaling_client.attach_load_balancers({
        auto_scaling_group_name: "basnik",
        load_balancer_names: ["Test"],
     })
    end
  end
end
