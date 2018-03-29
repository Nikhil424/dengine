require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/dengine_azurerm_base"
require 'securerandom'
require "#{File.dirname(__FILE__)}/base/dengine_azure_common_bootstrap_options"
require "#{File.dirname(__FILE__)}/base/dengine_azure_bootstrapper"
require "#{File.dirname(__FILE__)}/base/dengine_azure_ip_attributes"

class Chef
  class Knife
    class DengineAzureServerCreate < Knife

      include Knife::DengineAzurermBase
      include Chef::Knife::Bootstrap::DengineAzureCommonBootstrapOptions
      include Chef::Knife::Bootstrap::DengineAzureBootstrapper
      include Engine::DengineAzureIpAttributes

      banner "knife dengine azure server create (options)"

      attr_accessor :initial_sleep_delay

      option :ssh_user,
        :short => "-x USERNAME",
        :long => "--ssh-user USERNAME",
        :description => "The ssh username",
        :default => "root"

      option :ssh_password,
        :short => "-P PASSWORD",
        :long => "--ssh-password PASSWORD",
        :description => "The ssh password"

      option :ssh_port,
        :long => "--ssh-port PORT",
        :description => "The ssh port. Default is 22."

      option :node_ssl_verify_mode,
        :long        => "--node-ssl-verify-mode [peer|none]",
        :description => "Whether or not to verify the SSL cert for all HTTPS requests."

      option :winrm_user,
        :short => "-x USERNAME",
        :long => "--winrm-user USERNAME",
        :description => "The WinRM username",
        :default => "Administrator",
        :proc => Proc.new { |key| Chef::Config[:knife][:winrm_user] = key }

      option :winrm_password,
        :short => "-P PASSWORD",
        :long => "--winrm-password PASSWORD",
        :description => "The WinRM password",
        :proc => Proc.new { |key| Chef::Config[:knife][:winrm_password] = key }

      option :azure_storage_account,
        :short => "-a NAME",
        :long => "--azure-storage-account NAME",
        :description => "Required for advanced server-create option.
                                      A name for the storage account that is unique within Windows Azure. Storage account names must be
                                      between 3 and 24 characters in length and use numbers and lower-case letters only.
                                      This name is the DNS prefix name and can be used to access blobs, queues, and tables in the storage account.
                                      For example: http://ServiceName.blob.core.windows.net/mycontainer/"

      option :azure_storage_account_type,
        :long => "--azure-storage-account-type TYPE",
        :description => "Optional. One of the following account types (case-sensitive):
                                      Standard_LRS (Standard Locally-redundant storage)
                                      Standard_ZRS (Standard Zone-redundant storage)
                                      Standard_GRS (Standard Geo-redundant storage)
                                      Standard_RAGRS (Standard Read access geo-redundant storage)
                                      Premium_LRS (Premium Locally-redundant storage)",
        :default => 'Standard_GRS'

      option :azure_vm_name,
        :long => "--azure-vm-name NAME",
        :description => "Required. Specifies the name for the virtual machine.
                        The name must be unique within the ResourceGroup.
                        The azure vm name cannot be more than 15 characters long"

      option :azure_service_location,
        :short => "-m LOCATION",
        :long => "--azure-service-location LOCATION",
        :description => "Required if not using an Affinity Group. Specifies the geographic location - the name of the data center location that is valid for your subscription.
                                      Eg: westus, eastus, eastasia, southeastasia, northeurope, westeurope",
        :proc        => Proc.new { |lo| Chef::Config[:knife][:azure_service_location] = lo }

      option :azure_os_disk_name,
        :short => "-o DISKNAME",
        :long => "--azure-os-disk-name DISKNAME",
        :description => "Optional. Specifies the friendly name of the disk containing the guest OS image in the image repository."

      option :azure_image_reference_publisher,
        :long => "--azure-image-reference-publisher PUBLISHER_NAME",
        :description => "Optional. Specifies the publisher of the image used to create the virtual machine.
                          eg. OpenLogic, Canonical, MicrosoftWindowsServer"

      option :azure_image_reference_offer,
        :long => "--azure-image-reference-offer OFFER",
        :description => "Optional. Specifies the offer of the image used to create the virtual machine.
                          eg. CentOS, UbuntuServer, WindowsServer"

      option :azure_image_reference_sku,
        :long => "--azure-image-reference-sku SKU",
        :description => "Optional. Specifies the SKU of the image used to create the virtual machine."

      option :azure_image_reference_version,
        :long => "--azure-image-reference-version VERSION",
        :description => "Optional. Specifies the version of the image used to create the virtual machine.
                          Default value is 'latest'",
        :default => 'latest'

      option :azure_image_os_type,
        :long => "--azure-image-os-type OSTYPE",
        :description => "Optional. Specifies the image OS Type for which server needs to be created. Accepted values ubuntu|centos|rhel|debian|windows"

      option :azure_vm_size,
        :short => "-z SIZE",
        :long => "--azure-vm-size SIZE",
        :description => "Optional. Size of virtual machine (ExtraSmall, Small, Medium, Large, ExtraLarge)",
        :default => 'Small',
        :proc => Proc.new { |si| Chef::Config[:knife][:azure_vm_size] = si }

      option :azure_vnet_name,
        :long => "--azure-vnet-name VNET_NAME",
        :description => "Optional. Specifies the virtual network name.
                         This may be the name of an existing vnet present under the given resource group
                         or this may be the name of a new vnet to be added in the given resource group.
                         If not specified then azure-vm-name will be taken as the default name for vnet name as well.
                         Along with this option azure-vnet-subnet-name option can also be specified or it can also be skipped."

      option :azure_vnet_subnet_name,
        :long => "--azure-vnet-subnet-name VNET_SUBNET_NAME",
        :description => "Optional. Specifies the virtual network subnet name.
                         Must be specified only with azure-vnet-name option.
                         This may be the name of an existing subnet present under the given virtual network
                         or this may be the name of a new subnet to be added in the given virtual network.
                         If not specified then azure-vm-name will be taken as the default name for subnet name as well.
                         Value as 'GatewaySubnet' cannot be used as the name for the --azure-vnet-subnet-name option."

      option :ssh_public_key,
        :long => "--ssh-public-key FILENAME",
        :description => "It is the ssh-rsa public key path. Specify either ssh-password or ssh-public-key"

      option :thumbprint,
        :long => "--thumbprint THUMBPRINT",
        :description => "The thumprint of the ssl certificate"

      option :cert_passphrase,
        :long => "--cert-passphrase PASSWORD",
        :description => "SSL Certificate Password"

      option :cert_path,
        :long => "--cert-path PATH",
        :description => "SSL Certificate Path"

      option :tcp_endpoints,
        :short => "-t PORT_LIST",
        :long => "--tcp-endpoints PORT_LIST",
        :description => "Comma-separated list of TCP ports to open e.g. '80,433'"

      option :server_count,
        :long => "--server-count COUNT",
        :description => "Number of servers to create with same configuration.
                                    Maximum count is 5. Default value is 1.",
        :default => 1

      option :ohai_hints,
        :long => "--ohai-hints HINT_OPTIONS",
        :description => "Hint option names to be set in Ohai configuration of the target node.
                                     Supported values are: vm_name, public_fqdn and platform.
                                     User can pass any comma separated combination of these values like 'vm_name,public_fqdn'.
                                     Default value is 'default' which corresponds to the supported values list mentioned here.",
        :default => 'default'

      option :azure_availability_set,
        :long => "--availability-set AVAILABILITY_SET_NAME",
        :description => "Enter the name of availability set in which the VM has to be created.",
        :default => 'null'

      option :azure_loadbalancer_name,
        :long => "--loadbalancer-name LOADBALANCER_NAME",
        :description => "Enter the name of loadbalancer in which the VM has to be created.",
        :default => 'null'

      option :azure_vm_nat_rule,
        :long => "--vm-nat-rule VM_NAT_RULE",
        :description => "Enter the nat rule in which the VM has to be created.",
        :default => 'null'

      option :azure_backend_pool,
        :long => "--backend-pool BACKEND_POOL",
        :description => "Enter the backend pool in which the VM has to be created.",
        :default => 'null'

      def run
        $stdout.sync = true

        validate_arm_keys!(
          :azure_resource_group_name,
          :azure_vm_name,
          :azure_service_location
        )

        begin
          validate_params!

          set_default_image_reference!

          ssh_override_winrm if !is_image_windows?

          vm_details = service.create_server(create_server_def)

          ip_attr = get_ip_attributes(locate_config_value(:azure_resource_group_name), locate_config_value(:azure_vm_name))

          bootstrap_exec(ip_attr[0],ip_attr[1])
		  
        rescue => error
          service.common_arm_rescue_block(error)
          exit
        end
      end

        def get_node(name)
          node_query = Chef::Search::Query.new
          node_found = node_query.search('node', "name:#{name}").first
          return node_found
        end

      def create_server_def
        server_def = {
          :azure_resource_group_name => locate_config_value(:azure_resource_group_name),
          :azure_storage_account => locate_config_value(:azure_storage_account),
          :azure_storage_account_type => locate_config_value(:azure_storage_account_type),
          :azure_vm_name => locate_config_value(:azure_vm_name),
          :azure_service_location => locate_config_value(:azure_service_location),
          :azure_os_disk_name => locate_config_value(:azure_os_disk_name),
          :azure_os_disk_caching => locate_config_value(:azure_os_disk_caching),
          :azure_os_disk_create_option => locate_config_value(:azure_os_disk_create_option),
          :azure_vm_size => locate_config_value(:azure_vm_size),
          :azure_image_reference_publisher => locate_config_value(:azure_image_reference_publisher),
          :azure_image_reference_offer => locate_config_value(:azure_image_reference_offer),
          :azure_image_reference_sku => locate_config_value(:azure_image_reference_sku),
          :azure_image_reference_version => locate_config_value(:azure_image_reference_version),
          :winrm_user => locate_config_value(:winrm_user),
          :azure_vnet_name => locate_config_value(:azure_vnet_name),
          :azure_vnet_subnet_name => locate_config_value(:azure_vnet_subnet_name),
          :ssl_cert_fingerprint => locate_config_value(:thumbprint),
          :cert_path => locate_config_value(:cert_path),
          :cert_password => locate_config_value(:cert_passphrase),
          :vnet_subnet_address_prefix => locate_config_value(:vnet_subnet_address_prefix),
          :server_count => locate_config_value(:server_count),
          :azure_availability_set => locate_config_value(:azure_availability_set),
          :azure_loadbalancer_name => locate_config_value(:azure_loadbalancer_name),
          :azure_backend_pool => locate_config_value(:azure_backend_pool),
          :azure_vm_nat_rule => locate_config_value(:azure_vm_nat_rule)
        }

        server_def[:tcp_endpoints] = locate_config_value(:tcp_endpoints) if locate_config_value(:tcp_endpoints)

        # We assign azure_vm_name to chef_node_name If node name is nill because storage account name is combination of hash value and node name.
        config[:chef_node_name] ||= locate_config_value(:azure_vm_name)

        server_def[:azure_storage_account] = locate_config_value(:azure_vm_name) if server_def[:azure_storage_account].nil?
        server_def[:azure_storage_account] = server_def[:azure_storage_account].gsub(/[!@#$%^&*()_-]/,'')

        server_def[:azure_os_disk_name] = locate_config_value(:azure_vm_name) if server_def[:azure_os_disk_name].nil?
        server_def[:azure_os_disk_name] = server_def[:azure_os_disk_name].gsub(/[!@#$%^&*()_-]/,'')

        server_def[:azure_vnet_name] = locate_config_value(:azure_vm_name) if server_def[:azure_vnet_name].nil?
        server_def[:azure_vnet_subnet_name] = locate_config_value(:azure_vm_name) if locate_config_value(:azure_vnet_subnet_name).nil?

        server_def[:chef_extension] = get_chef_extension_name
        server_def[:chef_extension_publisher] = get_chef_extension_publisher
        server_def[:chef_extension_version] = locate_config_value(:azure_chef_extension_version)
        server_def[:chef_extension_public_param] = get_chef_extension_public_params
        server_def[:chef_extension_private_param] = get_chef_extension_private_params
        server_def[:auto_upgrade_minor_version] = false

        if is_image_windows?
          server_def[:admin_password] = locate_config_value(:winrm_password)
        else
          server_def[:ssh_user] = locate_config_value(:ssh_user)
          server_def[:ssh_password] = locate_config_value(:ssh_password)
          server_def[:disablePasswordAuthentication] = "false"
          if locate_config_value(:ssh_public_key)
            server_def[:disablePasswordAuthentication] = "true"
            server_def[:ssh_key] = File.read(locate_config_value(:ssh_public_key))
          end
        end

        server_def
      end

      def supported_ohai_hints
        [
          'vm_name',
          'public_fqdn',
          'platform',
          'public_ip'
        ]
      end

      def format_ohai_hints(ohai_hints)
        ohai_hints = ohai_hints.split(',').each { |hint| hint.strip! }
        ohai_hints.join(',')
      end

      def is_supported_ohai_hint?(hint)
        supported_ohai_hints.any? { |supported_ohai_hint| hint.eql? supported_ohai_hint }
      end

      def validate_ohai_hints
        hint_values = locate_config_value(:ohai_hints).split(',')
        hint_values.each do |hint|
          if ! is_supported_ohai_hint?(hint)
            raise ArgumentError, "Ohai Hint name #{hint} passed is not supported. Please run the command help to see the list of supported values."
          end
        end
      end

      private

      def ssh_override_winrm
        # unchanged ssh_user and changed winrm_user, override ssh_user
        if locate_config_value(:ssh_user).eql?(options[:ssh_user][:default]) &&
            !locate_config_value(:winrm_user).eql?(options[:winrm_user][:default])
          config[:ssh_user] = locate_config_value(:winrm_user)
        end

        if locate_config_value(:ssh_password).nil? &&
            !locate_config_value(:winrm_password).nil?
          config[:ssh_password] = locate_config_value(:winrm_password)
        end
      end

      def set_default_image_reference!
        begin
          if locate_config_value(:azure_image_os_type)
            if (locate_config_value(:azure_image_reference_publisher) || locate_config_value(:azure_image_reference_offer))
              # if azure_image_os_type is given and any of the other image reference parameters like publisher or offer are also given,
              # raise error
              raise ArgumentError, 'Please specify either --azure-image-os-type OR --azure-image-os-type with --azure-image-reference-sku or 4 image reference parameters i.e.
                --azure-image-reference-publisher, --azure-image-reference-offer, --azure-image-reference-sku, --azure-image-reference-version."'
            else
              ## if azure_image_os_type is given (with or without azure-image-reference-sku) and other image reference parameters are not given,
              # set default image reference parameters
              case locate_config_value(:azure_image_os_type)
              when "ubuntu"
                config[:azure_image_reference_publisher] = "Canonical"
                config[:azure_image_reference_offer] = "UbuntuServer"
                config[:azure_image_reference_sku] = locate_config_value(:azure_image_reference_sku) ? locate_config_value(:azure_image_reference_sku) : "14.04.2-LTS"
              when "centos"
                config[:azure_image_reference_publisher] = "OpenLogic"
                config[:azure_image_reference_offer] = "CentOS"
                config[:azure_image_reference_sku] = locate_config_value(:azure_image_reference_sku) ? locate_config_value(:azure_image_reference_sku) : "7.1"
              when "rhel"
                config[:azure_image_reference_publisher] = "RedHat"
                config[:azure_image_reference_offer] = "RHEL"
                config[:azure_image_reference_sku] = locate_config_value(:azure_image_reference_sku) ? locate_config_value(:azure_image_reference_sku) : "7.2"
              when "debian"
                config[:azure_image_reference_publisher] = "credativ"
                config[:azure_image_reference_offer] = "Debian"
                config[:azure_image_reference_sku] = locate_config_value(:azure_image_reference_sku) ? locate_config_value(:azure_image_reference_sku) : "7"
              when "windows"
                config[:azure_image_reference_publisher] = "MicrosoftWindowsServer"
                config[:azure_image_reference_offer] = "WindowsServer"
                config[:azure_image_reference_sku] = locate_config_value(:azure_image_reference_sku) ? locate_config_value(:azure_image_reference_sku) : "2012-R2-Datacenter"
              else
                raise ArgumentError, 'Invalid value of --azure-image-os-type. Accepted values ubuntu|centos|windows'
              end
            end
          else
            if (locate_config_value(:azure_image_reference_publisher) && locate_config_value(:azure_image_reference_offer) && locate_config_value(:azure_image_reference_sku) && locate_config_value(:azure_image_reference_version))
              # if azure_image_os_type is not given and other image reference parameters are given,
              # do nothing
            else
              # if azure_image_os_type is not given and other image reference parameters are also not given,
              # throw error for azure_image_os_type
              validate_arm_keys!(:azure_image_os_type)
            end
          end
        rescue => error
          ui.error("#{error.message}")
          Chef::Log.debug("#{error.backtrace.join("\n")}")
          exit
        end

        # final verification for image reference parameters
        validate_arm_keys!(:azure_image_reference_publisher,
            :azure_image_reference_offer,
            :azure_image_reference_sku,
            :azure_image_reference_version)
      end

      def bootstrap_for_node(fqdn,ip,port)
          bootstrap = Chef::Knife::Bootstrap.new
          bootstrap.name_args = fqdn
          bootstrap.config[:ssh_user] = locate_config_value(:ssh_user)
          bootstrap.config[:ssh_password] = locate_config_value(:ssh_password)
          bootstrap.config[:ssh_port] = port
          bootstrap.config[:identity_file] = locate_config_value(:identity_file)
          bootstrap.config[:chef_node_name] = locate_config_value(:chef_node_name)
          bootstrap.config[:use_sudo] = true unless locate_config_value(:ssh_user) == 'root'
          bootstrap.config[:use_sudo_password] = true if bootstrap.config[:use_sudo]
          bootstrap.config[:environment] = locate_config_value(:environment)
          # may be needed for vpc_mode
          bootstrap.config[:host_key_verify] = config[:host_key_verify]
          Chef::Config[:knife][:secret] = config[:encrypted_data_bag_secret] if config[:encrypted_data_bag_secret]
          Chef::Config[:knife][:secret_file] = config[:encrypted_data_bag_secret_file] if config[:encrypted_data_bag_secret_file]
          bootstrap.config[:secret] = locate_config_value(:encrypted_data_bag_secret)
          bootstrap.config[:secret_file] = locate_config_value(:encrypted_data_bag_secret_file)
          bootstrap.config[:bootstrap_install_command] = locate_config_value(:bootstrap_install_command)
          bootstrap.config[:bootstrap_wget_options] = locate_config_value(:bootstrap_wget_options)
          bootstrap.config[:bootstrap_curl_options] = locate_config_value(:bootstrap_curl_options)
          bootstrap_common_params(bootstrap,fqdn,ip)
        end
		
	def bootstrap_common_params(bootstrap,fqdn,ip)
          bootstrap.config[:run_list] = locate_config_value(:run_list)
          bootstrap.config[:prerelease] = locate_config_value(:prerelease)
          bootstrap.config[:first_boot_attributes] = locate_config_value(:json_attributes) || {}
          bootstrap.config[:bootstrap_version] = locate_config_value(:bootstrap_version)
          bootstrap.config[:distro] = locate_config_value(:distro) || default_bootstrap_template
          # setting bootstrap_template value to template_file for backward
          bootstrap.config[:template_file] = locate_config_value(:template_file) || locate_config_value(:bootstrap_template)
          bootstrap.config[:node_ssl_verify_mode] = locate_config_value(:node_ssl_verify_mode)
          bootstrap.config[:node_verify_api_cert] = locate_config_value(:node_verify_api_cert)
          bootstrap.config[:bootstrap_no_proxy] = locate_config_value(:bootstrap_no_proxy)
          bootstrap.config[:bootstrap_url] = locate_config_value(:bootstrap_url)
          bootstrap.config[:bootstrap_vault_file] = locate_config_value(:bootstrap_vault_file)
          bootstrap.config[:bootstrap_vault_json] = locate_config_value(:bootstrap_vault_json)
          bootstrap.config[:bootstrap_vault_item] = locate_config_value(:bootstrap_vault_item)

          load_cloud_attributes_in_hints(fqdn,ip)
          
          bootstrap
        end
		
	def load_cloud_attributes_in_hints(fqdn,ip)
          # Modify global configuration state to ensure hint gets set by knife-bootstrap
          # Query azure and load necessary attributes.
          cloud_attributes = {}
          cloud_attributes["public_ip"] = ip
          cloud_attributes["vm_name"] = locate_config_value(:chef_node_name)
          cloud_attributes["public_fqdn"] = fqdn
          cloud_attributes["public_ssh_port"] = locate_config_value(:ssh_port)
          
          Chef::Config[:knife][:hints] ||= {}
          Chef::Config[:knife][:hints]["azure"] ||= cloud_attributes
        end

    end
  end
end

