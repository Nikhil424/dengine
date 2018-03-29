require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/dengine_azure_interface"
require "#{File.dirname(__FILE__)}/base/dengine_aws_interface"
require "#{File.dirname(__FILE__)}/base/dengine_data_tresure"

module Engine
  class DengineAddInstanceLoadbalancer < Chef::Knife

    include DengineDataTresure

    banner 'knife dengine add instance loadbalancer (options)'

      option :elb_name,
        :short => '-n ELB-NAME',
        :long => '--name_elb ELB-NAME',
        :description => "The name of load balancer in which the server has to be added"

      option :instance_id,
        :short => '-i INSTANCE-ID',
        :long => '--instance_id INSTANCE-ID',
        :description => 'The ID of instance which has to be added to the LB-pool'

      option :type,
        :short => '-t ELB_TYPE',
        :long => '--type ELB_TYPE',
        :description => 'The type of the load balancer to which the instances has to be added, possible values are: network, application'

      option :cloud,
        :long => '--cloud CLOUD_PROVIDER_NAME',
        :description => "The name of the cloud provider for ex: aws, azure, google, openstack etc"

    def run

      if config[:cloud] == "aws"
        @client = DengineAwsInterface.new
      elsif config[:cloud] == "azure"
        puts "#{ui.color('we are in alfa, soon we will be here', :cyan)}"
        exit
        @client = ''
      elsif config[:cloud] == "google"
        puts "#{ui.color('we are in alfa, soon we will be here', :cyan)}"
        exit
        @client = ''
      elsif config[:cloud] == "openstack"
        puts "#{ui.color('we are in alfa, soon we will be here', :cyan)}"
        exit
        @client = ''
	  elsif (config[:cloud].nil?)
        Chef::Log.error "You have misspell the word or you might have not chose the cloud provider "
        exit
      end

      add_instances_to_loadbalancer

    end

    def add_instances_to_loadbalancer

      if config[:cloud] == "aws"
        @client.register_server_to_load_balancers("#{config[:elb_name]}","#{config[:instance_id]}","#{config[:type]}")
      elsif config[:cloud] == "azure"
      elsif config[:cloud] == "google"
      elsif config[:cloud] == "openstack"
      elsif (config[:cloud].nil?)
        exit
      end

    end

  end
end
