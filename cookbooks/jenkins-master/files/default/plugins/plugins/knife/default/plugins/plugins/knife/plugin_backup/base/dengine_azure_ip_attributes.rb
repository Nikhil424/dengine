require 'chef/knife'
require "#{File.dirname(__FILE__)}/dengine_azure_sdk_network_base"

module Engine
    module DengineAzureIpAttributes

    include DengineAzureSdkNetworkBase

#      def get_ip_attributes
      def get_ip_attributes(resource_group, name) 
#         promise = client.public_ipaddresses.get('Dengine', 'vm-3', custom_headers = nil)
         promise = client.public_ipaddresses.get(resource_group, name, custom_headers = nil)
         puts "Getting IP and FQDN"
         fqdn = promise.dns_settings.fqdn
         ip =  promise.ip_address
         return fqdn,ip
      end
    end
end
