require 'chef/knife'
require "/var/lib/jenkins/.chef/plugins/knife/base/dengine_client_base"

module Engine
    module DengineAzureIpAttributes

    include DengineClientBase

      def get_ip_attributes(resource_group, name) 
         promise = azure_network_client.public_ipaddresses.get(resource_group, name, custom_headers = nil)
         puts "Getting IP and FQDN"
         fqdn = promise.dns_settings.fqdn
         ip =  promise.ip_address
         return fqdn,ip
      end
    end
end
