require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/dengine_azure_fog_network_base"
require "#{File.dirname(__FILE__)}/base/dengine_azure_sdk_compute_base"


module Engine
  class DengineAzureLbCreate < Chef::Knife

    include DengineAzureFogNetworkBase
    include DengineAzureSdkComputeBase

    banner "knife dengine azure lb create (options)"

        option :env,
        :short => '-e ENVIRONMENT_NAME',
        :long => '--name ENVIRONMENT_NAME',
        :description => 'Give the name of the environment'

        option :resource_group,
        :short => '-r RESOURCE_GROUP_NAME',
        :long => '--resource-group-name RESOURCE_GROUP_NAME',
        :description => "The name of Resource group in which the network that has to be created"

    def run
        env = config[:env]
        resource_group = config[:resource_group]		
# Creating AvailabilitySet for Backend pool
        puts ""
        puts "Creating AvailabilitySet for Backend pool of Loadbalancer"
	params = AvailabilitySet.new
        params.platform_update_domain_count = 5
        params.platform_fault_domain_count = 2
        params.managed = true
        params.location = "CentralIndia"
	promise = client.availability_sets.create_or_update("#{resource_group}", "#{env}_availability_set", params)
        puts "name = #{promise.name}"
        puts "id = #{promise.id}"
		
# Creating Public IP for Loadbalancer
        puts ""
        puts "Creating Public IP for Loadbalancer"
        pubip = service.public_ips.create(
           name: "#{env}_lbip",
           resource_group: "#{resource_group}",
           location: 'CentralIndia',
           public_ip_allocation_method: Fog::ARM::Network::Models::IPAllocationMethod::Dynamic
        )
        puts "name = #{pubip.name}"
        puts "id = #{pubip.id}"

# Creating Loadbalancer
        puts ""
        puts "Creating Loadbalancer"
        lb = service.load_balancers.create(
        name: "#{env}_lb",
        resource_group: "#{resource_group}",
        location: 'CentralIndia',
              frontend_ip_configurations:
                  [
                    {
                      name: "#{env}_lbip",
                      private_ipallocation_method: Fog::ARM::Network::Models::IPAllocationMethod::Dynamic,
                      public_ipaddress_id: "/subscriptions/#{Chef::Config[:knife][:azure_subscription_id]}/resourceGroups/#{resource_group}/providers/Microsoft.Network/publicIPAddresses/#{env}_lbip"
                    }
                  ],
              backend_address_pool_names:
                  [
                      "#{env}_vm_pool"
                  ],
              probes:
                  [
                    {
                      name: 'HealthProbe',
                      protocol: 'http',
                      request_path: 'index.html',
                      port: '80',
                      interval_in_seconds: 5,
                      load_balancing_rules: 'lb_rule',
                      number_of_probes: 2,
                      load_balancing_rule_id: "/subscriptions/0594cd49-9185-425d-9fe2-8d051e4c6054/resourceGroups/#{resource_group}/providers/Microsoft.Network/loadBalancers/#{env}_lb/loadBalancingRules/lb_rule"
                    }
                  ],
              load_balancing_rules:
                  [
                    {
                      name: 'lb_rule',
                      frontend_ip_configuration_id: "/subscriptions/#{Chef::Config[:knife][:azure_subscription_id]}/resourceGroups/#{resource_group}/providers/Microsoft.Network/loadBalancers/#{env}_lb/frontendIPConfigurations/#{env}_lbip",
                      backend_address_pool_id: "/subscriptions/#{Chef::Config[:knife][:azure_subscription_id]}/resourceGroups/#{resource_group}/providers/Microsoft.Network/loadBalancers/#{env}_lb/backendAddressPools/#{env}_vm_pool",
                      protocol: 'Tcp',
                      frontend_port: '80',
                      backend_port: '80',
                      enable_floating_ip: false,
                      idle_timeout_in_minutes: 4,
                      load_distribution: "Default",
                      probe_id: "/subscriptions/0594cd49-9185-425d-9fe2-8d051e4c6054/resourceGroups/Dengine/providers/Microsoft.Network/loadBalancers/#{env}_lb/probes/HealthProbe"
                    }
                  ],
              inbound_nat_rules:
                  [
                    {
                      name: 'nat1',
                      frontend_ip_configuration_id: "/subscriptions/#{Chef::Config[:knife][:azure_subscription_id]}/resourceGroups/#{resource_group}/providers/Microsoft.Network/loadBalancers/#{env}_lb/frontendIPConfigurations/#{env}_lbip",
                      protocol: 'Tcp',
                      frontend_port: 1121,
                      port_mapping: false,
                      backend_port: 1211
                    },
                    {
                      name: 'nat2',
                      frontend_ip_configuration_id: "/subscriptions/#{Chef::Config[:knife][:azure_subscription_id]}/resourceGroups/#{resource_group}/providers/Microsoft.Network/loadBalancers/#{env}_lb/frontendIPConfigurations/#{env}_lbip",
                      protocol: 'Tcp',
                      frontend_port: 1122,
                      port_mapping: false,
                      backend_port: 1212
                    }
                  ]
        )
        puts "name = #{lb.name}"
        puts "id = #{lb.id}"
        backend_pool = lb.backend_address_pool_names[0] 
        puts "backend_pool = #{backend_pool.split("/")[-1]}"
      end
    end
  end

