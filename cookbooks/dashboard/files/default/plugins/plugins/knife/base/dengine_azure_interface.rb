require 'chef/knife'
require 'azure/storage'
require "#{File.dirname(__FILE__)}/dengine_client_base"
#require "#{File.dirname(__FILE__)}/azure/azure_server_create"

module Engine
  class DengineAzureInterface < Chef::Knife

    include DengineClientBase

    deps do
      require "#{File.dirname(__FILE__)}/azure/azure_server_create"
      Chef::Knife::AzureServerCreate.load_deps
    end
#---------------------Creation of VPN----------------------------
	
    def create_vpc(resource_group, name, vpn_cidr)

      params = VirtualNetwork.new

      address_space = AddressSpace.new
      address_space.address_prefixes = ["#{vpn_cidr}"]
      params.address_space = address_space

      params.location = 'CentralIndia'

      puts "#{ui.color('VPN creation has been started', :cyan)}"
      puts ''
      puts "#{ui.color('VPN creation in progress', :cyan)}"
      puts ''
      promise = azure_network_client.virtual_networks.create_or_update("#{resource_group}", "#{name}", params)
      puts "#{ui.color('VPN creation is completed', :cyan)}"
      puts ''
      puts "========================================================="
      puts "#{ui.color('VPN name is:', :magenta)}   :#{promise.name}"
      puts "#{ui.color('VPN id is:', :magenta)}     :#{promise.id}"
      puts "========================================================="

      return promise.name
    end

#----------------------Creation of Subnets------------------------

    def create_subnet(name,cidr,vpn_name,resource_group,id)

    nsg = create_security_group("#{name}_nsg_#{id}", resource_group)
          create_security_rule_for_nsg("rule_#{id}", nsg, cidr, resource_group)
    route = create_route_table("#{name}_route_#{id}", cidr, resource_group)
    

    subnet = azure_network_service.subnets.create(
      name: "#{name}_sub_#{id}",
      resource_group: "#{resource_group}",
      virtual_network_name: "#{vpn_name}",
      address_prefix: "#{cidr}",
      network_security_group_id: "/subscriptions/#{Chef::Config[:knife][:azure_subscription_id]}/resourceGroups/#{resource_group}/providers/Microsoft.Network/networkSecurityGroups/#{nsg}",
      route_table_id: "/subscriptions/#{Chef::Config[:knife][:azure_subscription_id]}/resourceGroups/#{resource_group}/providers/Microsoft.Network/routeTables/#{route}"
      )

      puts ''
      puts "========================================================="
      puts "#{ui.color('SUBNET name is:', :magenta)}   :#{subnet.name}"
      puts "#{ui.color('SUBNET id is:', :magenta)}     :#{subnet.id}"
      puts "========================================================="

      return subnet.name,nsg
    end

#-----------------------Creation of NSG--------------------------------
  
    def create_security_group(name, resource_group)

      params = NetworkSecurityGroup.new
      params.location = "CentralIndia"

      puts "#{ui.color('NSG creation has been started', :cyan)}"
      puts ''
      puts "#{ui.color('NSG creation in progress', :cyan)}"
      puts ''
      promise = azure_network_client.network_security_groups.create_or_update("#{resource_group}", "#{name}", params)
      puts "#{ui.color('NSG creation is completed', :cyan)}"
	  puts " "
      puts "========================================================="
      puts "#{ui.color('NSG name is:', :magenta)}   :#{promise.name}"
#	  puts "name = #{promise.name}"
      puts "#{ui.color('NSG id is:', :magenta)}     :#{promise.id}"
#      puts "id = #{promise.id}"
      puts "========================================================="

      return promise.name
    end

#----------Creation of Security Rule and adding to NSG	---------------
	
   def create_security_rule_for_nsg(name, nsg_name, sub_cidr, resource_group)

      params = SecurityRule.new
      params.description = "AllowSSHProtocol"
      params.protocol = 'Tcp'
      params.source_port_range = '*'
      params.destination_port_range = '*'
      params.source_address_prefix = '*'
      params.destination_address_prefix = "#{sub_cidr}"
      params.access = 'Allow'
      params.priority = '100'
      params.direction = 'Inbound'
      promise = azure_network_client.security_rules.create_or_update("#{resource_group}", "#{nsg_name}", "#{name}", params)
		
    end
	
#-----------------------Creation of ROUTE Table----------------------------

    def create_route_table(name, sub_cidr, resource_group)
      params = RouteTable.new

      rou = Route.new
      rou.name = "#{name}_route"
      rou.address_prefix = "#{sub_cidr}"
      rou.next_hop_type = 'VirtualNetworkGateway'

      params.routes = [rou]
      params.location = 'CentralIndia'
      puts "#{ui.color('Route table creation has been started', :cyan)}"
      puts ''
      puts "#{ui.color('Route table creation in progress', :cyan)}"
      puts ''
      route_table = azure_network_client.route_tables.create_or_update("#{resource_group}", "#{name}", params)
      puts "#{ui.color('Route table creation is completed', :cyan)}"
      puts " "

      return route_table.name
    end

#--------------------Creating AvailabilitySet for Backend pool---------------

    def create_availability_set(resource_group,name)
      puts ""
      puts "#{ui.color('Creating AvailabilitySet for Backend pool of Loadbalancer', :cyan)}"
      puts ""
      params = AvailabilitySet.new
      params.platform_update_domain_count = 5
      params.platform_fault_domain_count = 2
      params.managed = true
      params.location = "CentralIndia"
      puts ''
      puts "#{ui.color('avalablility set creation in progress', :cyan)}"
      promise = azure_compute_client.availability_sets.create_or_update("#{resource_group}", "#{name}-availability-set", params)
      puts ''
      puts "#{ui.color('avalablility set creation is completed', :cyan)}"
      puts "========================================================="
      puts "#{ui.color('avalablility set name:', :magenta)} :#{promise.name}"
      puts "#{ui.color('avalablility set id:', :magenta)}   :#{promise.id}"
      puts "========================================================="

      return promise.name
    end

#----------------Creating Public IP for Loadbalancer-------------------

    def create_public_ip(resource_group,name)
      puts ""
      puts "#{ui.color('Creating Public IP for Loadbalancer', :cyan)}"
      puts ""
      puts "#{ui.color('', :cyan)}"
      pubip = azure_network_service.public_ips.create(
         name: "#{name}-lbip",
         resource_group: "#{resource_group}",
         location: 'CentralIndia',
         public_ip_allocation_method: Fog::ARM::Network::Models::IPAllocationMethod::Dynamic,
         idle_timeout_in_minutes: 4,
         domain_name_label: "#{name}-lbip".downcase
      )
      puts ''
      puts "#{ui.color('Public IP creation is completed', :cyan)}"
      puts "========================================================="
      puts "#{ui.color('Public IP name:', :magenta)} :#{pubip.name}"
      puts "#{ui.color('Public IP id:', :magenta)}   :#{pubip.id}"
      puts "#{ui.color('Public IP FQDN:', :magenta)} :#{pubip.fqdn}"
      puts "========================================================="

      return pubip.fqdn
    end

#-------------------------Creating Loadbalancer-----------------------------

    def create_lb(resource_group,name)
      envmnt = "#{name}".downcase
      lb_dns_name = create_public_ip(resource_group,envmnt)
      puts ""
      puts "Creating Loadbalancer"
      lb = azure_network_service.load_balancers.create(
      name: "#{name}",
      resource_group: "#{resource_group}",
      location: 'CentralIndia',
            frontend_ip_configurations:
                [
                  {
                    name: "#{name}-lbip",
                    private_ipallocation_method: Fog::ARM::Network::Models::IPAllocationMethod::Dynamic,
                    public_ipaddress_id: "/subscriptions/#{Chef::Config[:knife][:azure_subscription_id]}/resourceGroups/#{resource_group}/providers/Microsoft.Network/publicIPAddresses/#{name}-lbip"
                  }
                ],
            backend_address_pool_names:
                [
                    "#{name}-vm-pool"
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
                    load_balancing_rule_id: "/subscriptions/0594cd49-9185-425d-9fe2-8d051e4c6054/resourceGroups/#{resource_group}/providers/Microsoft.Network/loadBalancers/#{name}/loadBalancingRules/lb-rule"
                  }
                ],
            load_balancing_rules:
                [
                  {
                    name: 'lb-rule',
                    frontend_ip_configuration_id: "/subscriptions/#{Chef::Config[:knife][:azure_subscription_id]}/resourceGroups/#{resource_group}/providers/Microsoft.Network/loadBalancers/#{name}/frontendIPConfigurations/#{name}-lbip",
                    backend_address_pool_id: "/subscriptions/#{Chef::Config[:knife][:azure_subscription_id]}/resourceGroups/#{resource_group}/providers/Microsoft.Network/loadBalancers/#{name}/backendAddressPools/#{name}-vm-pool",
                    protocol: 'Tcp',
                    frontend_port: '80',
                    backend_port: '80',
                    enable_floating_ip: false,
                    idle_timeout_in_minutes: 4,
                    load_distribution: "Default",
                    probe_id: "/subscriptions/0594cd49-9185-425d-9fe2-8d051e4c6054/resourceGroups/#{resource_group}/providers/Microsoft.Network/loadBalancers/#{name}/probes/HealthProbe"
                  }
                ],
            inbound_nat_rules:
                [
                  {
                    name: 'nat1',
                    frontend_ip_configuration_id: "/subscriptions/#{Chef::Config[:knife][:azure_subscription_id]}/resourceGroups/#{resource_group}/providers/Microsoft.Network/loadBalancers/#{name}/frontendIPConfigurations/#{name}-lbip",
                    protocol: 'Tcp',
                    frontend_port: 1121,
                    port_mapping: false,
                    backend_port: 1211
                  },
                  {
                    name: 'nat2',
                    frontend_ip_configuration_id: "/subscriptions/#{Chef::Config[:knife][:azure_subscription_id]}/resourceGroups/#{resource_group}/providers/Microsoft.Network/loadBalancers/#{name}/frontendIPConfigurations/#{name}-lbip",
                    protocol: 'Tcp',
                    frontend_port: 1122,
                    port_mapping: false,
                    backend_port: 1212
                  },
                  {
                    name: 'nat3',
                    frontend_ip_configuration_id: "/subscriptions/#{Chef::Config[:knife][:azure_subscription_id]}/resourceGroups/#{resource_group}/providers/Microsoft.Network/loadBalancers/#{name}/frontendIPConfigurations/#{name}-lbip",
                    protocol: 'Tcp',
                    frontend_port: 1123,
                    port_mapping: false,
                    backend_port: 1213
                  }
                ]
      )

      puts ''
      puts "#{ui.color('Loadbalancer creation is completed', :cyan)}"
      puts "========================================================="
      puts "#{ui.color('Loadbalancer name:', :magenta)}     :#{lb.name}"
      puts "#{ui.color('Loadbalancer id:', :magenta)}       :#{lb.id}"
      puts "#{ui.color('Loadbalancer dns name:', :magenta)} :#{lb_dns_name}"
      puts "========================================================="

      return lb_dns_name
    end

#---------------------------------resource creation--------------------------------

    def create_storage_account(resource_group,name)

      strage_name = name.downcase
      time = Time.new
      params = StorageAccountCreateParameters.new
      params.location = 'CentralIndia'
      sku = Sku.new
      sku.name = 'Standard_LRS'
      params.sku = sku
      params.kind = 'Storage'
      puts "Creating Storage Account #{time.hour}:#{time.min}:#{time.sec}"
      promise = azure_storage_client.storage_accounts.create("#{resource_group}", "#{name}", params)

      #---------storing a powershell script inside a container for bootstrapping windows-----

      storage_key = azure_storage_client.storage_accounts.list_keys(resource_group, name, custom_headers = nil)
      key = storage_key.keys.sample(1)

      client = Azure::Storage::Client.create(:storage_account_name => name, :storage_access_key => "#{key[0].value}")

      blobs = client.blob_client

      container = blobs.create_container('windows', :public_access_level => 'blob' )

      open("#{File.dirname(__FILE__)}/enable_winrm.ps1", "w") do |f|
        f.puts "Enable-PSRemoting -Force"
        f.puts "netsh advfirewall firewall add rule name='WinRM-HTTP' dir=in localport=5985 protocol=TCP action=allow"
      end
      content = ::File.open("#{File.dirname(__FILE__)}/enable_winrm.ps1", 'rb') { |file| file.read }
      blobs.create_block_blob(container.name, 'enable_winrm.ps1', content)
      File.delete("#{File.dirname(__FILE__)}/enable_winrm.ps1")

      t = Time.new
      puts "Created Storage Account #{t.hour}:#{t.min}:#{t.sec}"
    end

    def create_resource_group(name)

      params = Azure::ARM::Resources::Models::ResourceGroup.new
      params.location = 'CentralIndia'
      promise = azure_resource_client.resource_groups.create_or_update("#{name}", params, custom_headers = nil)
    end

#--------------------------------------server creation----------------------------------

    def create_server(resource_group,node_name,region,storage_account,storage_account_type,env,subnet,flavor,image,ssh_user,ssh_pub_key,availability_set,lb,nat_rule,chef_env,gateway_key,backend_pool,runlist,security_group)

      create = Chef::Knife::AzureServerCreate.new

      create.config[:flavor]                      = flavor
      create.config[:azure_image_os_type]         = image
      create.config[:azure_vm_name]               = node_name
      create.config[:ssh_user]                    = ssh_user
      create.config[:ssh_port]                    = 22
      create.config[:ssh_public_key]              = ssh_pub_key
      create.config[:ssh_gateway_identity]        = gateway_key
      create.config[:run_list]                    = runlist
      create.config[:azure_service_location]      = region
      create.config[:azure_vnet_subnet_name]      = subnet
      create.config[:azure_vnet_name]             = env
      create.config[:azure_storage_account]       = storage_account
      create.config[:azure_storage_account_type]  = storage_account_type
      create.config[:azure_availability_set]      = availability_set
      create.config[:azure_loadbalancer_name]     = lb
      create.config[:azure_vm_nat_rule]           = nat_rule
      create.config[:azure_backend_pool]          = backend_pool
      create.config[:azure_sec_group_name]        = security_group
      create.config[:azure_resource_group_name]   = resource_group
      create.config[:bootstrap_version]           = '12.21.31'

      create.config[:environment]                 = chef_env
      value = create.run

      puts "-------------------------"
      puts "NODE-NAME: #{node_name}"
      puts "ENV      : #{chef_env}"
      puts "-------------------------"
   end

  end
end
